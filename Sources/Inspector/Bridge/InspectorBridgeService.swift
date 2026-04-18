#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
import Foundation
import UIKit
import os.log

protocol InspectorBridgeSnapshotProtocol: ExpirableProtocol {
    var viewHierarchy: [ViewHierarchyElementReference] { get }
    var availableLayers: [ViewHierarchyLayer: Int] { get }
}

extension InspectorBridgeSnapshotProtocol {
    var availableLayers: [ViewHierarchyLayer: Int] { [:] }
}

extension ViewHierarchySnapshot: InspectorBridgeSnapshotProtocol {
    var viewHierarchy: [ViewHierarchyElementReference] { root.viewHierarchy }
}

protocol InspectorBridgeSnapshotRendering {
    func snapshot(
        for reference: ViewHierarchyElementReference,
        handle: InspectorBridgeHandle,
        afterScreenUpdates: Bool
    ) throws -> InspectorBridgeSnapshotArtifact
}

enum InspectorBridgeRuntimeAvailability {
    case disabled
    case notStarted
    case active
}

enum InspectorBridgeOperation {
    case query
    case resolve
    case refreshHandle
    case snapshot
    case subtree
    case inspect
    case tap
    case listActions
    case performAction
    case assertProperty
    case assertVisible
    case assertHierarchyContains
    case captureState
    case diffStates
    case saveScenario
    case listScenarios
    case deleteScenario
    case diffScenario
    case listProperties
    case setProperty
    case layers
    case toggleLayer
}

struct InspectorBridgeSnapshotRenderer: InspectorBridgeSnapshotRendering {
    let artifactLimitProvider: () -> Int
    let dateProvider: () -> Date

    init(
        artifactLimitProvider: @escaping () -> Int = { 32 },
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.artifactLimitProvider = artifactLimitProvider
        self.dateProvider = dateProvider
    }

    func snapshot(
        for reference: ViewHierarchyElementReference,
        handle: InspectorBridgeHandle,
        afterScreenUpdates: Bool
    ) throws -> InspectorBridgeSnapshotArtifact {
        let snapshotView: UIView

        switch InspectorSnapshotCapture.snapshotView(for: reference, afterScreenUpdates: afterScreenUpdates) {
        case let .success(view):
            snapshotView = view
        case let .failure(reason):
            throw InspectorBridgeError.snapshotUnavailable(reason.bridgeReason)
        }

        let bounds = CGRect(origin: .zero, size: snapshotView.bounds.size)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale

        let image = UIGraphicsImageRenderer(size: bounds.size, format: format).image { _ in
            snapshotView.frame = bounds
            snapshotView.drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }

        guard let pngData = image.pngData() else {
            throw InspectorBridgeError.snapshotUnavailable(.captureFailed)
        }

        let directory = inspectorSnapshotsDirectoryURL()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            os_log(.error, "inspector: failed to create snapshots directory at %{public}@: %{public}@",
                   directory.path, String(describing: error))
            throw InspectorBridgeError.snapshotUnavailable(.captureFailed)
        }

        let url = directory.appendingPathComponent("\(UUID().uuidString).png")
        do {
            try pngData.write(to: url, options: .atomic)
        } catch {
            os_log(.error, "inspector: failed to write snapshot PNG to %{public}@: %{public}@",
                   url.path, String(describing: error))
            throw InspectorBridgeError.snapshotUnavailable(.captureFailed)
        }

        pruneInspectorSnapshotsDirectory(limit: artifactLimitProvider())

        return InspectorBridgeSnapshotArtifact(
            handle: handle,
            pngURL: url,
            size: image.size,
            deviceScale: image.scale,
            createdAt: dateProvider()
        )
    }
}

func pruneInspectorSnapshotsDirectory(limit: Int) {
    let directory = inspectorSnapshotsDirectoryURL()
    let fileManager = FileManager.default

    guard
        let entries = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
    else {
        return
    }

    let cap = max(limit, 0)
    guard entries.count > cap else { return }

    let sorted = entries.sorted { lhs, rhs in
        let lhsDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
        let rhsDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
        return lhsDate < rhsDate
    }

    for url in sorted.prefix(sorted.count - cap) {
        try? fileManager.removeItem(at: url)
    }
}

final class InspectorMCPBridgeService {
    typealias AvailabilityProvider = () -> InspectorBridgeRuntimeAvailability
    typealias SnapshotProvider = () -> (any InspectorBridgeSnapshotProtocol)?
    typealias SnapshotLimitProvider = () -> Int
    typealias StateCaptureLimitProvider = () -> Int
    typealias DateProvider = () -> Date
    typealias LayerToggler = (ViewHierarchyLayer) -> Void
    typealias LayerActiveProvider = (ViewHierarchyLayer) -> Bool
    typealias LibrariesProvider = (InspectorBridgeEditablePanel) -> [InspectorElementLibraryProtocol]
    typealias ActionExecutor = (ViewHierarchyElementAction, ViewHierarchyElementReference) -> Void

    private struct HandleRecord {
        let reference: ViewHierarchyElementReference
        let objectIdentityToken: String
        let pathFingerprint: String
        let semanticReference: String
    }

    private struct PinnedSnapshot {
        let snapshot: any InspectorBridgeSnapshotProtocol
        let expiresAt: Date
        let handlesByToken: [String: HandleRecord]
        let handlesByReferenceID: [ObjectIdentifier: InspectorBridgeHandle]
    }

    private struct EditablePropertyRecord {
        let ownerHandle: InspectorBridgeHandle
        let ownerObjectIdentityToken: String
        let ownerPathFingerprint: String
        let binding: InspectorPropertyBinding
        let descriptor: InspectorBridgeEditablePropertyDescriptor
    }

    private struct ActionRecord {
        let ownerHandle: InspectorBridgeHandle
        let ownerObjectIdentityToken: String
        let ownerPathFingerprint: String
        let action: ViewHierarchyElementAction
        let descriptor: InspectorBridgeActionDescriptor
    }

    private struct CapturedStateRecord {
        let createdAt: Date
        let nodesBySignature: [String: InspectorBridgeCapturedNodeState]
    }

    private struct SavedScenarioRecord {
        let createdAt: Date
        let nodesBySignature: [String: InspectorBridgeCapturedNodeState]
    }

    private let availabilityProvider: AvailabilityProvider
    private let snapshotProvider: SnapshotProvider
    private let snapshotLimitProvider: SnapshotLimitProvider
    private let stateCaptureLimitProvider: StateCaptureLimitProvider
    private let snapshotRenderer: InspectorBridgeSnapshotRendering
    private let dateProvider: DateProvider
    private let layerToggler: LayerToggler
    private let layerActiveProvider: LayerActiveProvider
    private let librariesProvider: LibrariesProvider
    private let actionExecutor: ActionExecutor

    private var pinnedSnapshots: [UUID: PinnedSnapshot] = [:]
    private var handleIndex: [String: UUID] = [:]
    private var snapshotOrder: [UUID] = []
    private var semanticReferencesByHandle: [String: String] = [:]
    private var semanticReferenceOrder: [String] = []
    private var propertyRecords: [String: EditablePropertyRecord] = [:]
    private var propertyHandlesByOwner: [String: Set<String>] = [:]
    private var actionRecords: [String: ActionRecord] = [:]
    private var actionRefsByOwner: [String: Set<String>] = [:]
    private var stateCaptures: [String: CapturedStateRecord] = [:]
    private var stateCaptureOrder: [String] = []
    private var scenarios: [String: SavedScenarioRecord] = [:]

    var operationObserver: ((InspectorBridgeOperation, Bool) -> Void)?

    init(
        availabilityProvider: @escaping AvailabilityProvider,
        snapshotProvider: @escaping SnapshotProvider,
        snapshotLimitProvider: @escaping SnapshotLimitProvider = { 1 },
        stateCaptureLimitProvider: @escaping StateCaptureLimitProvider = { 8 },
        snapshotRenderer: InspectorBridgeSnapshotRendering = InspectorBridgeSnapshotRenderer(),
        dateProvider: @escaping DateProvider = Date.init,
        layerToggler: @escaping LayerToggler = { Inspector.sharedInstance.toggle($0) },
        layerActiveProvider: @escaping LayerActiveProvider = { Inspector.sharedInstance.isInspecting($0) },
        librariesProvider: @escaping LibrariesProvider = { _ in [] },
        actionExecutor: @escaping ActionExecutor = { action, element in
            guard let manager = Inspector.sharedInstance.manager else { return }
            let sourceView: UIView
            if let view = element._underlyingObject as? UIView {
                sourceView = view
            } else if let viewController = element._underlyingObject as? UIViewController {
                sourceView = viewController.view
            } else {
                sourceView = manager.keyWindow ?? UIView()
            }
            manager.perform(action: action, with: element, from: sourceView)
        }
    ) {
        self.availabilityProvider = availabilityProvider
        self.snapshotProvider = snapshotProvider
        self.snapshotLimitProvider = snapshotLimitProvider
        self.stateCaptureLimitProvider = stateCaptureLimitProvider
        self.snapshotRenderer = snapshotRenderer
        self.dateProvider = dateProvider
        self.layerToggler = layerToggler
        self.layerActiveProvider = layerActiveProvider
        self.librariesProvider = librariesProvider
        self.actionExecutor = actionExecutor
    }

    func reset() {
        pinnedSnapshots.removeAll()
        handleIndex.removeAll()
        snapshotOrder.removeAll()
        semanticReferencesByHandle.removeAll()
        semanticReferenceOrder.removeAll()
        propertyRecords.removeAll()
        propertyHandlesByOwner.removeAll()
        actionRecords.removeAll()
        actionRefsByOwner.removeAll()
        stateCaptures.removeAll()
        stateCaptureOrder.removeAll()
        scenarios.removeAll()
    }

    func query(_ request: InspectorBridgeQueryRequest = .init()) throws -> InspectorBridgeQueryResponse {
        try performOnMain(.query) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard let snapshot = self.snapshotProvider() else {
                throw InspectorBridgeError.snapshotUnavailable(.runtimeSnapshotUnavailable)
            }

            let pinnedSnapshot = self.pin(snapshot: snapshot)
            let nodes = snapshot.viewHierarchy
                .filter { self.matches($0, request: request) }
                .map { self.node(for: $0, in: pinnedSnapshot) }

            return InspectorBridgeQueryResponse(
                expiresAt: pinnedSnapshot.expiresAt,
                nodes: nodes
            )
        }
    }

    func resolve(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeNode {
        try performOnMain(.resolve) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            let (pinnedSnapshot, record) = try self.lookupRecord(for: handle)

            try self.validate(record: record, handle: handle)

            return self.node(for: record.reference, in: pinnedSnapshot)
        }
    }

    func refreshHandle(
        _ handle: InspectorBridgeHandle? = nil,
        semanticReference explicitSemanticReference: String? = nil
    ) throws -> InspectorBridgeRefreshHandleResult {
        try performOnMain(.refreshHandle) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard let snapshot = self.snapshotProvider() else {
                throw InspectorBridgeError.snapshotUnavailable(.runtimeSnapshotUnavailable)
            }

            let pinnedSnapshot = self.pin(snapshot: snapshot)
            let semanticReference = try self.resolveSemanticReference(
                handle: handle,
                explicitSemanticReference: explicitSemanticReference
            )
            let matches = snapshot.viewHierarchy.filter { self.semanticReference(for: $0) == semanticReference }

            guard let match = matches.only else {
                if matches.isEmpty {
                    throw InspectorBridgeError.unresolvedSemanticReference
                }
                throw InspectorBridgeError.ambiguousSemanticReference
            }

            let node = self.node(for: match, in: pinnedSnapshot)
            return InspectorBridgeRefreshHandleResult(
                handle: node.handle,
                semanticReference: semanticReference,
                expiresAt: pinnedSnapshot.expiresAt,
                rebound: handle.map { $0 != node.handle } ?? true
            )
        }
    }

    func snapshot(
        _ handle: InspectorBridgeHandle,
        afterScreenUpdates: Bool = true
    ) throws -> InspectorBridgeSnapshotArtifact {
        try performOnMain(.snapshot) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            let (_, record) = try self.lookupRecord(for: handle)
            try self.validate(record: record, handle: handle)

            return try self.snapshotRenderer.snapshot(
                for: record.reference,
                handle: handle,
                afterScreenUpdates: afterScreenUpdates
            )
        }
    }

    func subtree(
        _ handle: InspectorBridgeHandle,
        maxDepth: Int
    ) throws -> InspectorBridgeSubtreeResponse {
        try performOnMain(.subtree) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard maxDepth >= 0 else {
                throw InspectorBridgeError.invalidPropertyValue("maxDepth must be >= 0")
            }
            guard let snapshot = self.snapshotProvider() else {
                throw InspectorBridgeError.snapshotUnavailable(.runtimeSnapshotUnavailable)
            }

            let pinnedSnapshot = self.pin(snapshot: snapshot)
            let semanticReference = try self.resolveSemanticReference(handle: handle, explicitSemanticReference: nil)
            let matches = snapshot.viewHierarchy.filter { self.semanticReference(for: $0) == semanticReference }

            guard let root = matches.only else {
                if matches.isEmpty {
                    throw InspectorBridgeError.unresolvedSemanticReference
                }
                throw InspectorBridgeError.ambiguousSemanticReference
            }

            let rootNode = self.node(for: root, in: pinnedSnapshot)
            let nodes = self.collectSubtree(from: root, rootDepth: root._depth, maxDepth: maxDepth)
                .map { self.node(for: $0, in: pinnedSnapshot) }

            return InspectorBridgeSubtreeResponse(
                rootHandle: rootNode.handle,
                semanticReference: semanticReference,
                expiresAt: pinnedSnapshot.expiresAt,
                maxDepth: maxDepth,
                nodes: nodes
            )
        }
    }

    func inspect(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeHandle {
        try performOnMain(.inspect) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            let (_, record) = try self.lookupRecord(for: handle)
            try self.validate(record: record, handle: handle)

            guard let view = record.reference._underlyingObject as? UIView else {
                throw InspectorBridgeError.unsupportedTarget
            }

            Inspector.sharedInstance.inspect(view)
            return handle
        }
    }

    func tap(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeHandle {
        try performOnMain(.tap) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            let (_, record) = try self.lookupRecord(for: handle)
            try self.validate(record: record, handle: handle)

            guard let control = record.reference._underlyingObject as? UIControl else {
                throw InspectorBridgeError.internalFailure("handle is not a tappable UIControl")
            }

            guard control.window != nil else {
                throw InspectorBridgeError.internalFailure("control is not attached to a window")
            }

            guard control.isUserInteractionEnabled, !control.isHidden, control.alpha > 0.01 else {
                throw InspectorBridgeError.internalFailure("control is not interactable")
            }

            guard control.isEnabled else {
                throw InspectorBridgeError.internalFailure("control is not enabled")
            }

            let event: UIControl.Event
            if control.allControlEvents.contains(.primaryActionTriggered) {
                event = .primaryActionTriggered
            } else if control.allControlEvents.contains(.touchUpInside) {
                event = .touchUpInside
            } else {
                throw InspectorBridgeError.internalFailure("control does not expose a supported tap action")
            }

            control.sendActions(for: event)
            return handle
        }
    }

    func listProperties(
        for handle: InspectorBridgeHandle,
        panel: InspectorBridgeEditablePanel,
        includeReadOnly: Bool = false
    ) throws -> InspectorBridgePropertyListResponse {
        try performOnMain(.listProperties) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            let (pinnedSnapshot, record) = try self.lookupRecord(for: handle)
            try self.validate(record: record, handle: handle)

            guard let object = record.reference._underlyingObject else {
                throw InspectorBridgeError.staleHandle
            }

            let libraries = self.librariesProvider(panel)
            let sections = libraries.formItems(for: object)
            self.removePropertyHandles(for: handle)

            let editableSections = self.editableSections(
                from: sections,
                panel: panel,
                ownerHandle: handle,
                ownerRecord: record,
                includeReadOnly: includeReadOnly
            )

            return InspectorBridgePropertyListResponse(
                handle: handle,
                expiresAt: pinnedSnapshot.expiresAt,
                panel: panel,
                sections: editableSections
            )
        }
    }

    func listActions(
        for handle: InspectorBridgeHandle
    ) throws -> InspectorBridgeActionListResponse {
        try performOnMain(.listActions) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            let (pinnedSnapshot, record) = try self.lookupRecord(for: handle)
            try self.validate(record: record, handle: handle)

            self.removeActionRefs(for: handle)

            let actions = ViewHierarchyElementAction
                .allCases(for: record.reference)
                .compactMap { action in
                    self.makeActionDescriptor(
                        for: action,
                        ownerHandle: handle,
                        ownerRecord: record
                    )
                }

            return InspectorBridgeActionListResponse(
                handle: handle,
                expiresAt: pinnedSnapshot.expiresAt,
                actions: actions
            )
        }
    }

    func performAction(reference: String) throws -> InspectorBridgeActionResult {
        try performOnMain(.performAction) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard let actionRecord = self.actionRecords[reference] else {
                throw InspectorBridgeError.staleActionReference
            }

            let ownerRecord: HandleRecord
            do {
                let lookup = try self.lookupRecord(for: actionRecord.ownerHandle)
                ownerRecord = lookup.1
                try self.validate(record: ownerRecord, handle: actionRecord.ownerHandle)
            } catch InspectorBridgeError.staleHandle {
                self.removeActionRefs(for: actionRecord.ownerHandle)
                throw InspectorBridgeError.staleActionReference
            }

            guard ownerRecord.objectIdentityToken == actionRecord.ownerObjectIdentityToken,
                  ownerRecord.pathFingerprint == actionRecord.ownerPathFingerprint
            else {
                self.removeActionRefs(for: actionRecord.ownerHandle)
                throw InspectorBridgeError.staleActionReference
            }

            self.actionExecutor(actionRecord.action, ownerRecord.reference)
            self.removeActionRefs(for: actionRecord.ownerHandle)

            return InspectorBridgeActionResult(
                actionRef: reference,
                performed: true,
                refreshRecommended: true
            )
        }
    }

    func setProperty(
        reference: String,
        value: InspectorBridgePropertyMutationValue
    ) throws -> InspectorBridgePropertyMutationResult {
        try performOnMain(.setProperty) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard let propertyRecord = self.propertyRecords[reference] else {
                throw InspectorBridgeError.stalePropertyReference
            }

            let ownerRecord: HandleRecord
            do {
                let lookup = try self.lookupRecord(for: propertyRecord.ownerHandle)
                ownerRecord = lookup.1
                try self.validate(record: ownerRecord, handle: propertyRecord.ownerHandle)
            } catch InspectorBridgeError.staleHandle {
                self.removePropertyHandles(for: propertyRecord.ownerHandle)
                throw InspectorBridgeError.stalePropertyReference
            }

            guard ownerRecord.objectIdentityToken == propertyRecord.ownerObjectIdentityToken,
                  ownerRecord.pathFingerprint == propertyRecord.ownerPathFingerprint
            else {
                self.removePropertyHandles(for: propertyRecord.ownerHandle)
                throw InspectorBridgeError.stalePropertyReference
            }

            try self.apply(value: value, to: propertyRecord.binding)

            if let view = ownerRecord.reference._underlyingObject as? UIView {
                view._highlightView?.reloadData()
            }

            self.removePropertyHandles(for: propertyRecord.ownerHandle)

            return InspectorBridgePropertyMutationResult(
                propertyRef: reference,
                applied: true,
                refreshRecommended: true
            )
        }
    }

    func assertProperty(
        _ handle: InspectorBridgeHandle,
        property: InspectorBridgeAssertableProperty,
        expected: InspectorBridgeAssertionValue
    ) throws -> InspectorBridgeAssertPropertyResult {
        try performOnMain(.assertProperty) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            let node = try self.resolve(handle)

            switch property {
            case .className:
                let actual = node.className
                guard case let .string(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects stringValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: nil, actualNumber: nil, actualString: actual, message: "className is \(actual)")
            case .displayName:
                let actual = node.displayName
                guard case let .string(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects stringValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: nil, actualNumber: nil, actualString: actual, message: "displayName is \(actual)")
            case .elementName:
                let actual = node.elementName
                guard case let .string(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects stringValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: nil, actualNumber: nil, actualString: actual, message: "elementName is \(actual)")
            case .accessibilityIdentifier:
                let actual = node.accessibilityIdentifier
                guard case let .string(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects stringValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: nil, actualNumber: nil, actualString: actual, message: "accessibilityIdentifier is \(actual ?? "nil")")
            case .backingObjectType:
                let actual = node.backingObjectType
                guard case let .string(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects stringValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: nil, actualNumber: nil, actualString: actual, message: "backingObjectType is \(actual)")
            case .isHidden:
                let actual = node.isHidden
                guard case let .bool(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects boolValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: actual, actualNumber: nil, actualString: nil, message: "isHidden is \(actual)")
            case .isUserInteractionEnabled:
                let actual = node.isUserInteractionEnabled
                guard case let .bool(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects boolValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: actual, actualNumber: nil, actualString: nil, message: "isUserInteractionEnabled is \(actual)")
            case .isInternalView:
                let actual = node.isInternalView
                guard case let .bool(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects boolValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: actual, actualNumber: nil, actualString: nil, message: "isInternalView is \(actual)")
            case .isSystemContainer:
                let actual = node.isSystemContainer
                guard case let .bool(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects boolValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: actual, actualNumber: nil, actualString: nil, message: "isSystemContainer is \(actual)")
            case .childCount:
                let actual = Double(node.childCount)
                guard case let .number(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects numberValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: nil, actualNumber: actual, actualString: nil, message: "childCount is \(Int(actual))")
            case .depth:
                let actual = Double(node.depth)
                guard case let .number(expectedValue) = expected else {
                    throw InspectorBridgeError.invalidPropertyValue("property expects numberValue")
                }
                return .init(handle: handle, property: property, passed: actual == expectedValue, actualBool: nil, actualNumber: actual, actualString: nil, message: "depth is \(Int(actual))")
            }
        }
    }

    func assertVisible(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeAssertVisibleResult {
        try performOnMain(.assertVisible) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            let node = try self.resolve(handle)
            let passed = node.isHidden == false
            return .init(handle: handle, passed: passed, isHidden: node.isHidden, message: passed ? "node is visible" : "node is hidden")
        }
    }

    func assertHierarchyContains(
        _ request: InspectorBridgeQueryRequest,
        minimumCount: Int = 1
    ) throws -> InspectorBridgeAssertHierarchyContainsResult {
        try performOnMain(.assertHierarchyContains) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            let response = try self.query(request)
            let count = response.nodes.count
            let passed = count >= minimumCount
            return .init(
                passed: passed,
                matchCount: count,
                minimumCount: minimumCount,
                message: passed ? "hierarchy matched \(count) node(s)" : "hierarchy matched \(count) node(s), expected at least \(minimumCount)"
            )
        }
    }

    func captureState() throws -> InspectorBridgeStateCapture {
        try performOnMain(.captureState) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard let snapshot = self.snapshotProvider() else {
                throw InspectorBridgeError.snapshotUnavailable(.runtimeSnapshotUnavailable)
            }

            let nodes = snapshot.viewHierarchy.map(self.capturedNodeState(from:))
            let stateRef = UUID().uuidString
            self.stateCaptures[stateRef] = CapturedStateRecord(
                createdAt: self.dateProvider(),
                nodesBySignature: Dictionary(uniqueKeysWithValues: nodes.map { ($0.signature, $0) })
            )
            self.stateCaptureOrder.append(stateRef)
            self.enforceStateCaptureLimit()

            return InspectorBridgeStateCapture(
                stateRef: stateRef,
                createdAt: self.stateCaptures[stateRef]!.createdAt,
                nodeCount: nodes.count
            )
        }
    }

    func diffStates(before beforeRef: String, after afterRef: String) throws -> InspectorBridgeStateDiff {
        try performOnMain(.diffStates) {
            guard let before = self.stateCaptures[beforeRef] else {
                throw InspectorBridgeError.staleStateReference
            }
            guard let after = self.stateCaptures[afterRef] else {
                throw InspectorBridgeError.staleStateReference
            }

            let beforeKeys = Set(before.nodesBySignature.keys)
            let afterKeys = Set(after.nodesBySignature.keys)

            let added = afterKeys.subtracting(beforeKeys).compactMap { key -> InspectorBridgeStateDiffEntry? in
                guard let node = after.nodesBySignature[key] else { return nil }
                return .init(signature: key, kind: .added, className: node.className, elementName: node.elementName, accessibilityIdentifier: node.accessibilityIdentifier)
            }
            let removed = beforeKeys.subtracting(afterKeys).compactMap { key -> InspectorBridgeStateDiffEntry? in
                guard let node = before.nodesBySignature[key] else { return nil }
                return .init(signature: key, kind: .removed, className: node.className, elementName: node.elementName, accessibilityIdentifier: node.accessibilityIdentifier)
            }
            let changed = beforeKeys.intersection(afterKeys).compactMap { key -> InspectorBridgeStateDiffEntry? in
                guard let lhs = before.nodesBySignature[key], let rhs = after.nodesBySignature[key], lhs != rhs else { return nil }
                return .init(signature: key, kind: .changed, className: rhs.className, elementName: rhs.elementName, accessibilityIdentifier: rhs.accessibilityIdentifier)
            }

            let entries = added + removed + changed
            return InspectorBridgeStateDiff(
                beforeRef: beforeRef,
                afterRef: afterRef,
                addedCount: added.count,
                removedCount: removed.count,
                changedCount: changed.count,
                entries: entries
            )
        }
    }

    func saveScenario(named name: String) throws -> InspectorBridgeSavedScenario {
        try performOnMain(.captureState) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard let snapshot = self.snapshotProvider() else {
                throw InspectorBridgeError.snapshotUnavailable(.runtimeSnapshotUnavailable)
            }

            let nodes = snapshot.viewHierarchy.map(self.capturedNodeState(from:))
            let createdAt = self.dateProvider()
            self.scenarios[name] = SavedScenarioRecord(
                createdAt: createdAt,
                nodesBySignature: Dictionary(uniqueKeysWithValues: nodes.map { ($0.signature, $0) })
            )

            return InspectorBridgeSavedScenario(name: name, createdAt: createdAt, nodeCount: nodes.count)
        }
    }

    func listScenarios() throws -> [InspectorBridgeSavedScenario] {
        try performOnMain(.captureState) {
            self.scenarios
                .map { name, record in
                    InspectorBridgeSavedScenario(name: name, createdAt: record.createdAt, nodeCount: record.nodesBySignature.count)
                }
                .sorted { $0.name < $1.name }
        }
    }

    func deleteScenario(named name: String) throws {
        try performOnMain(.captureState) {
            guard self.scenarios.removeValue(forKey: name) != nil else {
                throw InspectorBridgeError.unknownScenario
            }
        }
    }

    func diffScenario(named name: String) throws -> InspectorBridgeScenarioDiff {
        try performOnMain(.diffStates) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard let scenario = self.scenarios[name] else {
                throw InspectorBridgeError.unknownScenario
            }
            guard let snapshot = self.snapshotProvider() else {
                throw InspectorBridgeError.snapshotUnavailable(.runtimeSnapshotUnavailable)
            }

            let currentNodes = Dictionary(uniqueKeysWithValues: snapshot.viewHierarchy.map { node in
                let captured = self.capturedNodeState(from: node)
                return (captured.signature, captured)
            })

            let beforeKeys = Set(scenario.nodesBySignature.keys)
            let afterKeys = Set(currentNodes.keys)

            let added = afterKeys.subtracting(beforeKeys).compactMap { key -> InspectorBridgeStateDiffEntry? in
                guard let node = currentNodes[key] else { return nil }
                return .init(signature: key, kind: .added, className: node.className, elementName: node.elementName, accessibilityIdentifier: node.accessibilityIdentifier)
            }
            let removed = beforeKeys.subtracting(afterKeys).compactMap { key -> InspectorBridgeStateDiffEntry? in
                guard let node = scenario.nodesBySignature[key] else { return nil }
                return .init(signature: key, kind: .removed, className: node.className, elementName: node.elementName, accessibilityIdentifier: node.accessibilityIdentifier)
            }
            let changed = beforeKeys.intersection(afterKeys).compactMap { key -> InspectorBridgeStateDiffEntry? in
                guard let lhs = scenario.nodesBySignature[key], let rhs = currentNodes[key], lhs != rhs else { return nil }
                return .init(signature: key, kind: .changed, className: rhs.className, elementName: rhs.elementName, accessibilityIdentifier: rhs.accessibilityIdentifier)
            }

            return InspectorBridgeScenarioDiff(
                name: name,
                addedCount: added.count,
                removedCount: removed.count,
                changedCount: changed.count,
                entries: added + removed + changed
            )
        }
    }

    private func enforceStateCaptureLimit() {
        let limit = max(self.stateCaptureLimitProvider(), 1)

        while self.stateCaptureOrder.count > limit {
            let oldest = self.stateCaptureOrder.removeFirst()
            self.stateCaptures.removeValue(forKey: oldest)
        }
    }

    func layers() throws -> [InspectorBridgeLayerState] {
        try performOnMain(.layers) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard let snapshot = self.snapshotProvider() else { return [] }

            return snapshot.availableLayers
                .filter { $0.value > 0 }
                .keys
                .sorted()
                .map { layer in
                    InspectorBridgeLayerState(
                        name: layer.name,
                        displayName: layer.description,
                        active: self.layerActiveProvider(layer)
                    )
                }
        }
    }

    func toggleLayer(name: String) throws -> InspectorBridgeLayerState {
        try performOnMain(.toggleLayer) {
            try self.ensureActive()
            self.cleanupExpiredSnapshots()

            guard let snapshot = self.snapshotProvider() else {
                throw InspectorBridgeError.internalFailure("no active snapshot")
            }

            guard let layer = snapshot.availableLayers.keys.first(where: { $0.name == name }) else {
                throw InspectorBridgeError.internalFailure("unknown layer: \(name)")
            }

            let wasActive = self.layerActiveProvider(layer)
            self.layerToggler(layer)
            return InspectorBridgeLayerState(
                name: layer.name,
                displayName: layer.description,
                active: !wasActive
            )
        }
    }

    private func ensureActive() throws {
        switch availabilityProvider() {
        case .disabled:
            throw InspectorBridgeError.disabled
        case .notStarted:
            throw InspectorBridgeError.notStarted
        case .active:
            break
        }
    }

    private func performOnMain<T>(
        _ operation: InspectorBridgeOperation,
        execute work: @escaping () throws -> T
    ) throws -> T {
        if Thread.isMainThread {
            operationObserver?(operation, true)
            return try work()
        }

        var result: Result<T, Error>!
        DispatchQueue.main.sync {
            operationObserver?(operation, Thread.isMainThread)
            result = Result { try work() }
        }

        return try result.get()
    }

    private func cleanupExpiredSnapshots() {
        let expiredSnapshotIDs = pinnedSnapshots.compactMap { snapshotID, pinnedSnapshot in
            pinnedSnapshot.expiresAt > dateProvider() ? nil : snapshotID
        }

        for snapshotID in expiredSnapshotIDs {
            remove(snapshotID: snapshotID)
        }
    }

    private func editableSections(
        from sections: InspectorElementSections,
        panel: InspectorBridgeEditablePanel,
        ownerHandle: InspectorBridgeHandle,
        ownerRecord: HandleRecord,
        includeReadOnly: Bool
    ) -> [InspectorBridgeEditablePropertySection] {
        sections.enumerated().compactMap { (sectionIndex: Int, section: InspectorElementSection) -> InspectorBridgeEditablePropertySection? in
            let rows = section.dataSources.enumerated().compactMap { (rowIndex: Int, row: InspectorElementSectionDataSource) -> InspectorBridgeEditablePropertyRow? in
                let properties = self.editableProperties(
                    from: row,
                    panel: panel,
                    sectionIndex: sectionIndex,
                    rowIndex: rowIndex,
                    ownerHandle: ownerHandle,
                    ownerRecord: ownerRecord,
                    includeReadOnly: includeReadOnly
                )

                guard !properties.isEmpty else { return nil }

                return InspectorBridgeEditablePropertyRow(
                    title: row.title,
                    subtitle: row.subtitle,
                    properties: properties
                )
            }

            guard !rows.isEmpty else { return nil }
            return InspectorBridgeEditablePropertySection(title: section.title, rows: rows)
        }
    }

    private func editableProperties(
        from row: InspectorElementSectionDataSource,
        panel: InspectorBridgeEditablePanel,
        sectionIndex: Int,
        rowIndex: Int,
        ownerHandle: InspectorBridgeHandle,
        ownerRecord: HandleRecord,
        includeReadOnly: Bool
    ) -> [InspectorBridgeEditablePropertyDescriptor] {
        var descriptors: [InspectorBridgeEditablePropertyDescriptor] = []

        if let titleAccessory = row.titleAccessoryBinding,
           let descriptor = makeDescriptor(
            for: titleAccessory,
            panel: panel,
            sectionIndex: sectionIndex,
            rowIndex: rowIndex,
            slot: .titleAccessory,
            propertyIndex: 0,
            ownerHandle: ownerHandle,
            ownerRecord: ownerRecord,
            includeReadOnly: includeReadOnly
           )
        {
            descriptors.append(descriptor)
        }

        for (propertyIndex, property) in row.propertyBindings.enumerated() {
            guard let descriptor = makeDescriptor(
                for: property,
                panel: panel,
                sectionIndex: sectionIndex,
                rowIndex: rowIndex,
                slot: .property,
                propertyIndex: propertyIndex,
                ownerHandle: ownerHandle,
                ownerRecord: ownerRecord,
                includeReadOnly: includeReadOnly
            ) else {
                continue
            }
            descriptors.append(descriptor)
        }

        return descriptors
    }

    private func makeActionDescriptor(
        for action: ViewHierarchyElementAction,
        ownerHandle: InspectorBridgeHandle,
        ownerRecord: HandleRecord
    ) -> InspectorBridgeActionDescriptor? {
        let kind: InspectorBridgeActionKind
        switch action {
        case let .inspect(preferredPanel: _):
            kind = .inspect
        case let .layer(layerAction):
            switch layerAction {
            case .showHighlight:
                kind = .showHighlight
            case .hideHighlight:
                kind = .hideHighlight
            }
        case .copy:
            return nil
        }

        let actionRef = UUID().uuidString
        let descriptor = InspectorBridgeActionDescriptor(
            actionRef: actionRef,
            title: action.title,
            kind: kind
        )

        actionRecords[actionRef] = ActionRecord(
            ownerHandle: ownerHandle,
            ownerObjectIdentityToken: ownerRecord.objectIdentityToken,
            ownerPathFingerprint: ownerRecord.pathFingerprint,
            action: action,
            descriptor: descriptor
        )
        actionRefsByOwner[ownerHandle.rawValue, default: []].insert(actionRef)
        return descriptor
    }

    private func makeDescriptor(
        for property: InspectorPropertyBinding,
        panel: InspectorBridgeEditablePanel,
        sectionIndex: Int,
        rowIndex: Int,
        slot: InspectorBridgeEditablePropertySlot,
        propertyIndex: Int,
        ownerHandle: InspectorBridgeHandle,
        ownerRecord: HandleRecord,
        includeReadOnly: Bool
    ) -> InspectorBridgeEditablePropertyDescriptor? {
        guard let base = descriptorBase(for: property) else { return nil }
        guard includeReadOnly || base.editable else { return nil }

        let propertyRef = UUID().uuidString
        let path = InspectorBridgeEditablePropertyPath(
            panel: panel,
            section: sectionIndex,
            row: rowIndex,
            slot: slot,
            index: propertyIndex
        )

        let descriptor = InspectorBridgeEditablePropertyDescriptor(
            propertyRef: propertyRef,
            path: path,
            title: base.title,
            kind: base.kind,
            editable: base.editable,
            boolValue: base.boolValue,
            numberValue: base.numberValue,
            stringValue: base.stringValue,
            selectionIndex: base.selectionIndex,
            minimum: base.minimum,
            maximum: base.maximum,
            step: base.step,
            isDecimal: base.isDecimal,
            options: base.options,
            nullable: base.nullable
        )

        propertyRecords[propertyRef] = EditablePropertyRecord(
            ownerHandle: ownerHandle,
            ownerObjectIdentityToken: ownerRecord.objectIdentityToken,
            ownerPathFingerprint: ownerRecord.pathFingerprint,
            binding: property,
            descriptor: descriptor
        )
        propertyHandlesByOwner[ownerHandle.rawValue, default: []].insert(propertyRef)
        return descriptor
    }

    private func descriptorBase(
        for property: InspectorPropertyBinding
    ) -> (
        title: String,
        kind: InspectorBridgeEditablePropertyKind,
        editable: Bool,
        boolValue: Bool?,
        numberValue: Double?,
        stringValue: String?,
        selectionIndex: Int?,
        minimum: Double?,
        maximum: Double?,
        step: Double?,
        isDecimal: Bool?,
        options: [String]?,
        nullable: Bool
    )? {
        let editable = property.write != nil
        switch (property.descriptor.kind, property.descriptor.value, property.currentValue()) {
        case let (.toggle, .bool, .bool(value)):
            return (property.descriptor.title, .toggle, editable, value, nil, nil, nil, nil, nil, nil, nil, nil, false)
        case let (.stepper, .number(numberConstraints), .number(value)):
            return (
                property.descriptor.title,
                .stepper,
                editable,
                nil,
                value,
                nil,
                nil,
                numberConstraints?.min,
                numberConstraints?.max,
                numberConstraints?.step,
                numberConstraints?.isDecimal,
                nil,
                false
            )
        case let (.textField, .string, .string(value)):
            return (property.descriptor.title, .textField, editable, nil, nil, value, nil, nil, nil, nil, nil, nil, true)
        case let (.textView, .string, .string(value)):
            return (property.descriptor.title, .textView, editable, nil, nil, value, nil, nil, nil, nil, nil, nil, true)
        case let (.options, .selection(selectionConstraints), .selection(index)):
            return (property.descriptor.title, .optionsList, editable, nil, nil, nil, index, nil, nil, nil, nil, selectionConstraints.options.map(\.title), true)
        case let (.textButtons, .selection(selectionConstraints), .selection(index)):
            return (property.descriptor.title, .textButtonGroup, editable, nil, nil, nil, index, nil, nil, nil, nil, selectionConstraints.options.map(\.title), true)
        case let (.imageButtons, .selection(selectionConstraints), .selection(index)):
            return (property.descriptor.title, .imageButtonGroup, editable, nil, nil, nil, index, 0, Double(max(selectionConstraints.options.count - 1, 0)), 1, false, selectionConstraints.options.map(\.title), true)
        default:
            return nil
        }
    }

    private func apply(
        value: InspectorBridgePropertyMutationValue,
        to property: InspectorPropertyBinding
    ) throws {
        guard property.write != nil else {
            throw InspectorBridgeError.internalFailure("property is read-only")
        }

        switch (property.descriptor.kind, property.descriptor.value, value) {
        case let (.toggle, .bool, .bool(boolValue)):
            property.apply(.bool(boolValue))
        case let (.stepper, .number(numberConstraints), .number(numberValue)):
            let min = numberConstraints?.min ?? 0
            let max = numberConstraints?.max ?? Double.infinity
            guard (min...max).contains(numberValue) else {
                throw InspectorBridgeError.invalidPropertyValue("value is outside the allowed range")
            }
            property.apply(.number(numberValue))
        case let (.textField, .string, .string(stringValue)),
             let (.textView, .string, .string(stringValue)):
            property.apply(.string(stringValue))
        case let (.options, .selection(selectionConstraints), .selection(selectionIndex)),
             let (.textButtons, .selection(selectionConstraints), .selection(selectionIndex)),
             let (.imageButtons, .selection(selectionConstraints), .selection(selectionIndex)):
            if let selectionIndex {
                guard selectionConstraints.options.indices.contains(selectionIndex) else {
                    throw InspectorBridgeError.invalidPropertyValue("selectionIndex is out of bounds")
                }
            }
            property.apply(.selection(selectionIndex))
        default:
            throw InspectorBridgeError.invalidPropertyValue("supplied value does not match property kind")
        }
    }

    private func pin(snapshot: any InspectorBridgeSnapshotProtocol) -> PinnedSnapshot {
        let snapshotID = UUID()

        var handlesByToken: [String: HandleRecord] = [:]
        var handlesByReferenceID: [ObjectIdentifier: InspectorBridgeHandle] = [:]

        for reference in snapshot.viewHierarchy {
            let token = UUID().uuidString
            let handle = InspectorBridgeHandle(rawValue: token)
            let referenceID = ObjectIdentifier(reference)

            let record = HandleRecord(
                reference: reference,
                objectIdentityToken: objectIdentityToken(for: reference),
                pathFingerprint: pathFingerprint(for: reference),
                semanticReference: semanticReference(for: reference)
            )

            handlesByToken[token] = record
            handlesByReferenceID[referenceID] = handle
            handleIndex[token] = snapshotID
            semanticReferencesByHandle[token] = record.semanticReference
            semanticReferenceOrder.append(token)
        }

        let pinnedSnapshot = PinnedSnapshot(
            snapshot: snapshot,
            expiresAt: snapshot.expirationDate,
            handlesByToken: handlesByToken,
            handlesByReferenceID: handlesByReferenceID
        )

        pinnedSnapshots[snapshotID] = pinnedSnapshot
        snapshotOrder.append(snapshotID)
        enforceSnapshotLimit()
        enforceSemanticReferenceLimit()
        return pinnedSnapshot
    }

    private func enforceSnapshotLimit() {
        let limit = max(snapshotLimitProvider(), 1)

        while snapshotOrder.count > limit {
            remove(snapshotID: snapshotOrder[0])
        }
    }

    private func enforceSemanticReferenceLimit() {
        let limit = max(snapshotLimitProvider(), 1) * 128

        while semanticReferenceOrder.count > limit {
            let token = semanticReferenceOrder.removeFirst()
            semanticReferencesByHandle.removeValue(forKey: token)
        }
    }

    private func lookupRecord(
        for handle: InspectorBridgeHandle
    ) throws -> (PinnedSnapshot, HandleRecord) {
        guard
            let snapshotID = handleIndex[handle.rawValue],
            let pinnedSnapshot = pinnedSnapshots[snapshotID]
        else {
            throw InspectorBridgeError.staleHandle
        }

        guard pinnedSnapshot.expiresAt > dateProvider() else {
            remove(snapshotID: snapshotID)
            throw InspectorBridgeError.staleHandle
        }

        guard let record = pinnedSnapshot.handlesByToken[handle.rawValue] else {
            throw InspectorBridgeError.staleHandle
        }

        return (pinnedSnapshot, record)
    }

    private func remove(handle: InspectorBridgeHandle) {
        guard let snapshotID = handleIndex[handle.rawValue] else {
            return
        }

        remove(snapshotID: snapshotID)
    }

    private func remove(snapshotID: UUID) {
        guard let removedSnapshot = pinnedSnapshots.removeValue(forKey: snapshotID) else {
            return
        }

        snapshotOrder.removeAll { $0 == snapshotID }

        for token in removedSnapshot.handlesByToken.keys {
            removePropertyHandles(for: .init(rawValue: token))
            removeActionRefs(for: .init(rawValue: token))
            handleIndex.removeValue(forKey: token)
        }
    }

    private func removePropertyHandles(for ownerHandle: InspectorBridgeHandle) {
        guard let propertyRefs = propertyHandlesByOwner.removeValue(forKey: ownerHandle.rawValue) else {
            return
        }

        for propertyRef in propertyRefs {
            propertyRecords.removeValue(forKey: propertyRef)
        }
    }

    private func removeActionRefs(for ownerHandle: InspectorBridgeHandle) {
        guard let actionRefs = actionRefsByOwner.removeValue(forKey: ownerHandle.rawValue) else {
            return
        }

        for actionRef in actionRefs {
            actionRecords.removeValue(forKey: actionRef)
        }
    }

    private func validate(
        record: HandleRecord,
        handle: InspectorBridgeHandle
    ) throws {
        guard record.reference._underlyingObject != nil else {
            remove(handle: handle)
            throw InspectorBridgeError.staleHandle
        }

        guard objectIdentityToken(for: record.reference) == record.objectIdentityToken,
              pathFingerprint(for: record.reference) == record.pathFingerprint
        else {
            remove(handle: handle)
            throw InspectorBridgeError.staleHandle
        }
    }

    private func resolveSemanticReference(
        handle: InspectorBridgeHandle?,
        explicitSemanticReference: String?
    ) throws -> String {
        if let explicitSemanticReference = normalized(explicitSemanticReference) {
            return explicitSemanticReference
        }

        guard let handle else {
            throw InspectorBridgeError.invalidPropertyValue("either handle or semanticReference is required")
        }

        if let snapshotID = handleIndex[handle.rawValue],
           let pinnedSnapshot = pinnedSnapshots[snapshotID],
           let record = pinnedSnapshot.handlesByToken[handle.rawValue]
        {
            return record.semanticReference
        }

        if let semanticReference = semanticReferencesByHandle[handle.rawValue] {
            return semanticReference
        }

        throw InspectorBridgeError.staleHandle
    }

    private func collectSubtree(
        from root: ViewHierarchyElementReference,
        rootDepth _: Int,
        maxDepth: Int
    ) -> [ViewHierarchyElementReference] {
        var results: [ViewHierarchyElementReference] = []

        func visit(_ node: ViewHierarchyElementReference, depth: Int) {
            guard depth <= maxDepth else { return }
            results.append(node)
            node.children.forEach { visit($0, depth: depth + 1) }
        }

        visit(root, depth: 0)
        return results
    }

    private func node(
        for reference: ViewHierarchyElementReference,
        in pinnedSnapshot: PinnedSnapshot
    ) -> InspectorBridgeNode {
        let referenceID = ObjectIdentifier(reference)
        guard let handle = pinnedSnapshot.handlesByReferenceID[referenceID] else {
            preconditionFailure("Pinned snapshot is missing a handle for reference \(reference._className)")
        }
        let parentHandle = reference.parent.flatMap { pinnedSnapshot.handlesByReferenceID[ObjectIdentifier($0)] }
        let childHandles = reference.children.compactMap { pinnedSnapshot.handlesByReferenceID[ObjectIdentifier($0)] }

        return InspectorBridgeNode(
            handle: handle,
            semanticReference: semanticReference(for: reference),
            nodeKind: nodeKind(for: reference),
            backingObjectType: reference._className,
            className: reference._className,
            displayName: reference._displayName,
            elementName: reference._elementName,
            accessibilityIdentifier: reference.accessibilityIdentifier,
            frame: reference._frame.wrappedValue,
            isHidden: reference.isHidden,
            isUserInteractionEnabled: reference.isUserInteractionEnabled,
            isInternalView: reference._isInternalView,
            isSystemContainer: reference._isSystemContainer,
            depth: reference._depth,
            parentHandle: parentHandle,
            childHandles: childHandles,
            childCount: reference.children.count
        )
    }

    private func capturedNodeState(from reference: ViewHierarchyElementReference) -> InspectorBridgeCapturedNodeState {
        InspectorBridgeCapturedNodeState(
            signature: stateSignature(for: reference),
            nodeKind: nodeKind(for: reference),
            className: reference._className,
            elementName: reference._elementName,
            accessibilityIdentifier: reference.accessibilityIdentifier,
            isHidden: reference.isHidden,
            isUserInteractionEnabled: reference.isUserInteractionEnabled,
            isInternalView: reference._isInternalView,
            isSystemContainer: reference._isSystemContainer,
            childCount: reference.children.count,
            depth: reference._depth
        )
    }

    private func stateSignature(for reference: ViewHierarchyElementReference) -> String {
        let parentSegment = reference.parent.map(stateSignature(for:)) ?? "root"
        let siblingIndex = reference.parent?.children.firstIndex(where: { $0 === reference }) ?? 0
        return "\(parentSegment)/\(reference._classNameWithoutQualifiers)#\(siblingIndex)|\(reference._elementName)|\(reference.accessibilityIdentifier ?? "")"
    }

    private func semanticReference(for reference: ViewHierarchyElementReference) -> String {
        let classPath = (
            reference.allParents
                .reversed()
                .map(\._classNameWithoutQualifiers)
            + [reference._classNameWithoutQualifiers]
        ).joined(separator: "/")

        return "\(classPath)#\(reference._depth)|\(reference._elementName)|\(reference.accessibilityIdentifier ?? "")"
    }

    private func matches(
        _ reference: ViewHierarchyElementReference,
        request: InspectorBridgeQueryRequest
    ) -> Bool {
        if let expectedNodeKind = request.nodeKind, expectedNodeKind != nodeKind(for: reference) {
            return false
        }

        if let value = normalized(request.classNameContains),
           !reference._className.localizedCaseInsensitiveContains(value)
        {
            return false
        }

        if let value = normalized(request.displayNameContains),
           !reference._displayName.localizedCaseInsensitiveContains(value)
        {
            return false
        }

        if let value = normalized(request.elementNameContains),
           !reference._elementName.localizedCaseInsensitiveContains(value)
        {
            return false
        }

        if let accessibilityIdentifier = normalized(request.accessibilityIdentifierEquals),
           reference.accessibilityIdentifier?.trimmingCharacters(in: .whitespacesAndNewlines) != accessibilityIdentifier
        {
            return false
        }

        if let expectedInternalView = request.isInternalView,
           reference._isInternalView != expectedInternalView
        {
            return false
        }

        if let expectedSystemContainer = request.isSystemContainer,
           reference._isSystemContainer != expectedSystemContainer
        {
            return false
        }

        return true
    }

    private func normalized(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        return value
    }
}

private func nodeKind(for reference: ViewHierarchyElementReference) -> InspectorBridgeNodeKind {
    if reference is ViewHierarchyElementController {
        return .viewController
    }

    if reference._underlyingObject is UIWindow {
        return .window
    }

    return .view
}

private func objectIdentityToken(for reference: ViewHierarchyElementReference) -> String {
    String(reference._objectIdentifier.hashValue)
}

private func pathFingerprint(for reference: ViewHierarchyElementReference) -> String {
    let path = reference
        .allParents
        .reversed()
        .map(\._classNameWithoutQualifiers)
        + [reference._classNameWithoutQualifiers]

    return path.joined(separator: "/") + "#\(reference._depth)"
}

private extension Collection {
    var only: Element? {
        count == 1 ? first : nil
    }
}

private let sharedInspectorMCPBridgeService = InspectorMCPBridgeService(
    availabilityProvider: {
        let inspector = Inspector.sharedInstance

        guard inspector.configuration.enableMCPBridge else {
            return .disabled
        }

        guard inspector.state == .started else {
            return .notStarted
        }

        return .active
    },
    snapshotProvider: {
        Inspector.sharedInstance.manager?.snapshot
    },
    snapshotLimitProvider: {
        Inspector.sharedInstance.configuration.snapshotMaxCount
    },
    snapshotRenderer: InspectorBridgeSnapshotRenderer(
        artifactLimitProvider: {
            Inspector.sharedInstance.configuration.snapshotArtifactMaxCount
        }
    ),
    librariesProvider: { panel in
        guard let manager = Inspector.sharedInstance.manager else { return [] }

        let inspectorPanel: ElementInspectorPanel
        switch panel {
        case .identity:
            inspectorPanel = .identity
        case .attributes:
            inspectorPanel = .attributes
        case .size:
            inspectorPanel = .size
        }

        return manager.catalog.libraries[inspectorPanel] ?? []
    }
)

let inspectorSnapshotsDirectoryName = "inspector-snapshots"

func inspectorSnapshotsDirectoryURL() -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(inspectorSnapshotsDirectoryName, isDirectory: true)
}

func cleanupInspectorSnapshotsDirectory() {
    try? FileManager.default.removeItem(at: inspectorSnapshotsDirectoryURL())
}

func resetInspectorBridgeState() {
    sharedInspectorMCPBridgeService.reset()
}

package extension Inspector {
    static func bridgeQuery(_ request: InspectorBridgeQueryRequest = .init()) throws -> InspectorBridgeQueryResponse {
        try sharedInspectorMCPBridgeService.query(request)
    }

    static func bridgeResolve(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeNode {
        try sharedInspectorMCPBridgeService.resolve(handle)
    }

    static func bridgeRefreshHandle(
        _ handle: InspectorBridgeHandle? = nil,
        semanticReference: String? = nil
    ) throws -> InspectorBridgeRefreshHandleResult {
        try sharedInspectorMCPBridgeService.refreshHandle(handle, semanticReference: semanticReference)
    }

    static func bridgeSnapshot(
        _ handle: InspectorBridgeHandle,
        afterScreenUpdates: Bool = true
    ) throws -> InspectorBridgeSnapshotArtifact {
        try sharedInspectorMCPBridgeService.snapshot(handle, afterScreenUpdates: afterScreenUpdates)
    }

    static func bridgeSubtree(
        _ handle: InspectorBridgeHandle,
        maxDepth: Int
    ) throws -> InspectorBridgeSubtreeResponse {
        try sharedInspectorMCPBridgeService.subtree(handle, maxDepth: maxDepth)
    }

    static func bridgeInspect(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeHandle {
        try sharedInspectorMCPBridgeService.inspect(handle)
    }

    static func bridgeTap(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeHandle {
        try sharedInspectorMCPBridgeService.tap(handle)
    }

    static func bridgeListActions(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeActionListResponse {
        try sharedInspectorMCPBridgeService.listActions(for: handle)
    }

    static func bridgePerformAction(reference: String) throws -> InspectorBridgeActionResult {
        try sharedInspectorMCPBridgeService.performAction(reference: reference)
    }

    static func bridgeAssertProperty(
        _ handle: InspectorBridgeHandle,
        property: InspectorBridgeAssertableProperty,
        expected: InspectorBridgeAssertionValue
    ) throws -> InspectorBridgeAssertPropertyResult {
        try sharedInspectorMCPBridgeService.assertProperty(handle, property: property, expected: expected)
    }

    static func bridgeAssertVisible(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeAssertVisibleResult {
        try sharedInspectorMCPBridgeService.assertVisible(handle)
    }

    static func bridgeAssertHierarchyContains(
        _ request: InspectorBridgeQueryRequest,
        minimumCount: Int = 1
    ) throws -> InspectorBridgeAssertHierarchyContainsResult {
        try sharedInspectorMCPBridgeService.assertHierarchyContains(request, minimumCount: minimumCount)
    }

    static func bridgeCaptureState() throws -> InspectorBridgeStateCapture {
        try sharedInspectorMCPBridgeService.captureState()
    }

    static func bridgeDiffStates(before beforeRef: String, after afterRef: String) throws -> InspectorBridgeStateDiff {
        try sharedInspectorMCPBridgeService.diffStates(before: beforeRef, after: afterRef)
    }

    static func bridgeSaveScenario(named name: String) throws -> InspectorBridgeSavedScenario {
        try sharedInspectorMCPBridgeService.saveScenario(named: name)
    }

    static func bridgeListScenarios() throws -> [InspectorBridgeSavedScenario] {
        try sharedInspectorMCPBridgeService.listScenarios()
    }

    static func bridgeDeleteScenario(named name: String) throws {
        try sharedInspectorMCPBridgeService.deleteScenario(named: name)
    }

    static func bridgeDiffScenario(named name: String) throws -> InspectorBridgeScenarioDiff {
        try sharedInspectorMCPBridgeService.diffScenario(named: name)
    }

    static func bridgeListProperties(
        _ handle: InspectorBridgeHandle,
        panel: InspectorBridgeEditablePanel,
        includeReadOnly: Bool = false
    ) throws -> InspectorBridgePropertyListResponse {
        try sharedInspectorMCPBridgeService.listProperties(for: handle, panel: panel, includeReadOnly: includeReadOnly)
    }

    static func bridgeSetProperty(
        reference: String,
        value: InspectorBridgePropertyMutationValue
    ) throws -> InspectorBridgePropertyMutationResult {
        try sharedInspectorMCPBridgeService.setProperty(reference: reference, value: value)
    }

    static func bridgeLayers() throws -> [InspectorBridgeLayerState] {
        try sharedInspectorMCPBridgeService.layers()
    }

    static func bridgeToggleLayer(name: String) throws -> InspectorBridgeLayerState {
        try sharedInspectorMCPBridgeService.toggleLayer(name: name)
    }
}

private extension InspectorSnapshotCaptureFailure {
    var bridgeReason: InspectorBridgeSnapshotUnavailableReason {
        switch self {
        case .lostConnection:
            .lostConnection
        case .noWindow:
            .noWindow
        case .frameIsEmpty:
            .frameIsEmpty
        case .isHidden:
            .isHidden
        case .captureFailed:
            .captureFailed
        }
    }
}
#endif
