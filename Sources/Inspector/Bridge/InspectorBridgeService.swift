#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
import Foundation
import UIKit
import os.log

protocol InspectorBridgeSnapshotProtocol: ExpirableProtocol {
    var viewHierarchy: [ViewHierarchyElementReference] { get }
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
    case snapshot
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
    typealias DateProvider = () -> Date

    private struct HandleRecord {
        let reference: ViewHierarchyElementReference
        let objectIdentityToken: String
        let pathFingerprint: String
    }

    private struct PinnedSnapshot {
        let snapshot: any InspectorBridgeSnapshotProtocol
        let expiresAt: Date
        let handlesByToken: [String: HandleRecord]
        let handlesByReferenceID: [ObjectIdentifier: InspectorBridgeHandle]
    }

    private let availabilityProvider: AvailabilityProvider
    private let snapshotProvider: SnapshotProvider
    private let snapshotLimitProvider: SnapshotLimitProvider
    private let snapshotRenderer: InspectorBridgeSnapshotRendering
    private let dateProvider: DateProvider

    private var pinnedSnapshots: [UUID: PinnedSnapshot] = [:]
    private var handleIndex: [String: UUID] = [:]
    private var snapshotOrder: [UUID] = []

    var operationObserver: ((InspectorBridgeOperation, Bool) -> Void)?

    init(
        availabilityProvider: @escaping AvailabilityProvider,
        snapshotProvider: @escaping SnapshotProvider,
        snapshotLimitProvider: @escaping SnapshotLimitProvider = { 1 },
        snapshotRenderer: InspectorBridgeSnapshotRendering = InspectorBridgeSnapshotRenderer(),
        dateProvider: @escaping DateProvider = Date.init
    ) {
        self.availabilityProvider = availabilityProvider
        self.snapshotProvider = snapshotProvider
        self.snapshotLimitProvider = snapshotLimitProvider
        self.snapshotRenderer = snapshotRenderer
        self.dateProvider = dateProvider
    }

    func reset() {
        pinnedSnapshots.removeAll()
        handleIndex.removeAll()
        snapshotOrder.removeAll()
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
                pathFingerprint: pathFingerprint(for: reference)
            )

            handlesByToken[token] = record
            handlesByReferenceID[referenceID] = handle
            handleIndex[token] = snapshotID
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
        return pinnedSnapshot
    }

    private func enforceSnapshotLimit() {
        let limit = max(snapshotLimitProvider(), 1)

        while snapshotOrder.count > limit {
            remove(snapshotID: snapshotOrder[0])
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
            handleIndex.removeValue(forKey: token)
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
            nodeKind: nodeKind(for: reference),
            backingObjectType: reference._className,
            className: reference._className,
            displayName: reference._displayName,
            elementName: reference._elementName,
            accessibilityIdentifier: reference.accessibilityIdentifier,
            frame: reference._frame.wrappedValue,
            isHidden: reference.isHidden,
            isUserInteractionEnabled: reference.isUserInteractionEnabled,
            depth: reference._depth,
            parentHandle: parentHandle,
            childHandles: childHandles,
            childCount: reference.children.count
        )
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
    )
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

    static func bridgeSnapshot(
        _ handle: InspectorBridgeHandle,
        afterScreenUpdates: Bool = true
    ) throws -> InspectorBridgeSnapshotArtifact {
        try sharedInspectorMCPBridgeService.snapshot(handle, afterScreenUpdates: afterScreenUpdates)
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
