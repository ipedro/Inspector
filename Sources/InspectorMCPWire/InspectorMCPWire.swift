import Foundation

public enum InspectorMCPBridgeEndpoint {
    public static let host = "127.0.0.1"
    public static let port: UInt16 = 49_321
    public static let healthPath = "/health"
    public static let queryPath = "/query"
    public static let resolvePath = "/resolve"
    public static let refreshHandlePath = "/refresh-handle"
    public static let snapshotPath = "/snapshot"
    public static let subtreePath = "/subtree"
    public static let inspectPath = "/inspect"
    public static let tapPath = "/tap"
    public static let actionsPath = "/actions"
    public static let performActionPath = "/perform-action"
    public static let assertPropertyPath = "/assert-property"
    public static let assertVisiblePath = "/assert-visible"
    public static let assertHierarchyContainsPath = "/assert-hierarchy-contains"
    public static let captureStatePath = "/capture-state"
    public static let diffStatesPath = "/diff-states"
    public static let saveScenarioPath = "/save-scenario"
    public static let scenariosPath = "/scenarios"
    public static let deleteScenarioPath = "/delete-scenario"
    public static let diffScenarioPath = "/diff-scenario"
    public static let propertiesPath = "/properties"
    public static let setPropertyPath = "/set-property"
    public static let layersPath = "/layers"
    public static let toggleLayerPath = "/toggle-layer"
    public static let baseURL = URL(string: "http://\(host):\(port)")!
}

public enum InspectorMCPOperation: String, Codable, CaseIterable {
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

public enum InspectorMCPHealthStatus: String, Codable {
    case disabled
    case notStarted
    case active
}

public struct InspectorMCPHealthResponse: Codable, Equatable {
    public let status: InspectorMCPHealthStatus
    public let bridgeEnabled: Bool
    public let inspectorStarted: Bool
    public let keyboardWindowsFiltered: Bool?
    public let bundleIdentifier: String?
    public let operations: [InspectorMCPOperation]
    public let apiVersion: Int?

    public init(
        status: InspectorMCPHealthStatus,
        bridgeEnabled: Bool,
        inspectorStarted: Bool,
        keyboardWindowsFiltered: Bool? = nil,
        bundleIdentifier: String?,
        operations: [InspectorMCPOperation],
        apiVersion: Int? = nil
    ) {
        self.status = status
        self.bridgeEnabled = bridgeEnabled
        self.inspectorStarted = inspectorStarted
        self.keyboardWindowsFiltered = keyboardWindowsFiltered
        self.bundleIdentifier = bundleIdentifier
        self.operations = operations
        self.apiVersion = apiVersion
    }
}

public enum InspectorMCPNodeKind: String, Codable {
    case window
    case viewController
    case view
}

public enum InspectorMCPEditablePanel: String, Codable {
    case identity
    case attributes
    case size
}

public enum InspectorMCPEditablePropertyKind: String, Codable {
    case toggle
    case stepper
    case textField
    case textView
    case optionsList
    case textButtonGroup
    case imageButtonGroup
}

public enum InspectorMCPEditablePropertySlot: String, Codable {
    case property
    case titleAccessory
}

public enum InspectorMCPActionKind: String, Codable {
    case inspect
    case showHighlight
    case hideHighlight
}

public enum InspectorMCPAssertableProperty: String, Codable {
    case className
    case displayName
    case elementName
    case accessibilityIdentifier
    case backingObjectType
    case isHidden
    case isUserInteractionEnabled
    case isInternalView
    case isSystemContainer
    case childCount
    case depth
}

public struct InspectorMCPFrame: Codable, Equatable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

public struct InspectorMCPSize: Codable, Equatable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

public struct InspectorMCPQueryRequest: Codable, Equatable {
    public var nodeKind: InspectorMCPNodeKind?
    public var classNameContains: String?
    public var displayNameContains: String?
    public var elementNameContains: String?
    public var accessibilityIdentifierEquals: String?
    public var isInternalView: Bool?
    public var isSystemContainer: Bool?

    public init(
        nodeKind: InspectorMCPNodeKind? = nil,
        classNameContains: String? = nil,
        displayNameContains: String? = nil,
        elementNameContains: String? = nil,
        accessibilityIdentifierEquals: String? = nil,
        isInternalView: Bool? = nil,
        isSystemContainer: Bool? = nil
    ) {
        self.nodeKind = nodeKind
        self.classNameContains = classNameContains
        self.displayNameContains = displayNameContains
        self.elementNameContains = elementNameContains
        self.accessibilityIdentifierEquals = accessibilityIdentifierEquals
        self.isInternalView = isInternalView
        self.isSystemContainer = isSystemContainer
    }
}

public struct InspectorMCPResolveRequest: Codable, Equatable {
    public let handle: String

    public init(handle: String) {
        self.handle = handle
    }
}

public struct InspectorMCPRefreshHandleRequest: Codable, Equatable {
    public let handle: String?
    public let semanticReference: String?

    public init(handle: String? = nil, semanticReference: String? = nil) {
        self.handle = handle
        self.semanticReference = semanticReference
    }
}

public struct InspectorMCPSnapshotRequest: Codable, Equatable {
    public let handle: String
    public let afterScreenUpdates: Bool

    public init(handle: String, afterScreenUpdates: Bool) {
        self.handle = handle
        self.afterScreenUpdates = afterScreenUpdates
    }
}

public struct InspectorMCPSubtreeRequest: Codable, Equatable {
    public let handle: String
    public let maxDepth: Int

    public init(handle: String, maxDepth: Int) {
        self.handle = handle
        self.maxDepth = maxDepth
    }
}

public struct InspectorMCPInspectRequest: Codable, Equatable {
    public let handle: String

    public init(handle: String) {
        self.handle = handle
    }
}

public struct InspectorMCPTapRequest: Codable, Equatable {
    public let handle: String

    public init(handle: String) {
        self.handle = handle
    }
}

public struct InspectorMCPPropertyListRequest: Codable, Equatable {
    public let handle: String
    public let panel: InspectorMCPEditablePanel
    public let includeReadOnly: Bool

    public init(handle: String, panel: InspectorMCPEditablePanel, includeReadOnly: Bool = false) {
        self.handle = handle
        self.panel = panel
        self.includeReadOnly = includeReadOnly
    }
}

public struct InspectorMCPSetPropertyRequest: Codable, Equatable {
    public let propertyRef: String
    public let boolValue: Bool?
    public let numberValue: Double?
    public let stringValue: String?
    public let selectionIndex: Int?

    public init(
        propertyRef: String,
        boolValue: Bool? = nil,
        numberValue: Double? = nil,
        stringValue: String? = nil,
        selectionIndex: Int? = nil
    ) {
        self.propertyRef = propertyRef
        self.boolValue = boolValue
        self.numberValue = numberValue
        self.stringValue = stringValue
        self.selectionIndex = selectionIndex
    }
}

public struct InspectorMCPActionListRequest: Codable, Equatable {
    public let handle: String

    public init(handle: String) {
        self.handle = handle
    }
}

public struct InspectorMCPPerformActionRequest: Codable, Equatable {
    public let actionRef: String

    public init(actionRef: String) {
        self.actionRef = actionRef
    }
}

public struct InspectorMCPAssertPropertyRequest: Codable, Equatable {
    public let handle: String
    public let property: InspectorMCPAssertableProperty
    public let boolValue: Bool?
    public let numberValue: Double?
    public let stringValue: String?

    public init(
        handle: String,
        property: InspectorMCPAssertableProperty,
        boolValue: Bool? = nil,
        numberValue: Double? = nil,
        stringValue: String? = nil
    ) {
        self.handle = handle
        self.property = property
        self.boolValue = boolValue
        self.numberValue = numberValue
        self.stringValue = stringValue
    }
}

public struct InspectorMCPAssertVisibleRequest: Codable, Equatable {
    public let handle: String

    public init(handle: String) {
        self.handle = handle
    }
}

public struct InspectorMCPAssertHierarchyContainsRequest: Codable, Equatable {
    public let nodeKind: InspectorMCPNodeKind?
    public let classNameContains: String?
    public let displayNameContains: String?
    public let elementNameContains: String?
    public let accessibilityIdentifierEquals: String?
    public let isInternalView: Bool?
    public let isSystemContainer: Bool?
    public let minimumCount: Int

    public init(
        nodeKind: InspectorMCPNodeKind? = nil,
        classNameContains: String? = nil,
        displayNameContains: String? = nil,
        elementNameContains: String? = nil,
        accessibilityIdentifierEquals: String? = nil,
        isInternalView: Bool? = nil,
        isSystemContainer: Bool? = nil,
        minimumCount: Int = 1
    ) {
        self.nodeKind = nodeKind
        self.classNameContains = classNameContains
        self.displayNameContains = displayNameContains
        self.elementNameContains = elementNameContains
        self.accessibilityIdentifierEquals = accessibilityIdentifierEquals
        self.isInternalView = isInternalView
        self.isSystemContainer = isSystemContainer
        self.minimumCount = minimumCount
    }
}

public struct InspectorMCPCaptureStateRequest: Codable, Equatable {
    public init() {}
}

public struct InspectorMCPDiffStatesRequest: Codable, Equatable {
    public let beforeRef: String
    public let afterRef: String

    public init(beforeRef: String, afterRef: String) {
        self.beforeRef = beforeRef
        self.afterRef = afterRef
    }
}

public struct InspectorMCPSaveScenarioRequest: Codable, Equatable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct InspectorMCPDeleteScenarioRequest: Codable, Equatable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct InspectorMCPDiffScenarioRequest: Codable, Equatable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct InspectorMCPNode: Codable, Equatable {
    public let handle: String
    public let semanticReference: String
    public let nodeKind: InspectorMCPNodeKind
    public let backingObjectType: String
    public let className: String
    public let displayName: String
    public let elementName: String
    public let accessibilityIdentifier: String?
    public let frame: InspectorMCPFrame
    public let isHidden: Bool
    public let isUserInteractionEnabled: Bool
    public let isInternalView: Bool
    public let isSystemContainer: Bool
    public let depth: Int
    public let parentHandle: String?
    public let childHandles: [String]
    public let childCount: Int

    public init(
        handle: String,
        semanticReference: String = "",
        nodeKind: InspectorMCPNodeKind,
        backingObjectType: String,
        className: String,
        displayName: String,
        elementName: String,
        accessibilityIdentifier: String?,
        frame: InspectorMCPFrame,
        isHidden: Bool,
        isUserInteractionEnabled: Bool,
        isInternalView: Bool,
        isSystemContainer: Bool,
        depth: Int,
        parentHandle: String?,
        childHandles: [String],
        childCount: Int
    ) {
        self.handle = handle
        self.semanticReference = semanticReference
        self.nodeKind = nodeKind
        self.backingObjectType = backingObjectType
        self.className = className
        self.displayName = displayName
        self.elementName = elementName
        self.accessibilityIdentifier = accessibilityIdentifier
        self.frame = frame
        self.isHidden = isHidden
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.isInternalView = isInternalView
        self.isSystemContainer = isSystemContainer
        self.depth = depth
        self.parentHandle = parentHandle
        self.childHandles = childHandles
        self.childCount = childCount
    }
}

public struct InspectorMCPRefreshHandleResult: Codable, Equatable {
    public let handle: String
    public let semanticReference: String
    public let expiresAt: Date
    public let rebound: Bool

    public init(handle: String, semanticReference: String, expiresAt: Date, rebound: Bool) {
        self.handle = handle
        self.semanticReference = semanticReference
        self.expiresAt = expiresAt
        self.rebound = rebound
    }
}

public struct InspectorMCPSubtreeResult: Codable, Equatable {
    public let rootHandle: String
    public let semanticReference: String
    public let expiresAt: Date
    public let maxDepth: Int
    public let nodes: [InspectorMCPNode]

    public init(rootHandle: String, semanticReference: String, expiresAt: Date, maxDepth: Int, nodes: [InspectorMCPNode]) {
        self.rootHandle = rootHandle
        self.semanticReference = semanticReference
        self.expiresAt = expiresAt
        self.maxDepth = maxDepth
        self.nodes = nodes
    }
}

public struct InspectorMCPQueryResult: Codable, Equatable {
    public let expiresAt: Date
    public let nodes: [InspectorMCPNode]

    public init(expiresAt: Date, nodes: [InspectorMCPNode]) {
        self.expiresAt = expiresAt
        self.nodes = nodes
    }
}

public struct InspectorMCPSnapshotResult: Codable, Equatable {
    public let handle: String
    public let mimeType: String
    public let pngPath: String
    public let size: InspectorMCPSize
    public let deviceScale: Double
    public let createdAt: Date

    public init(
        handle: String,
        mimeType: String,
        pngPath: String,
        size: InspectorMCPSize,
        deviceScale: Double,
        createdAt: Date
    ) {
        self.handle = handle
        self.mimeType = mimeType
        self.pngPath = pngPath
        self.size = size
        self.deviceScale = deviceScale
        self.createdAt = createdAt
    }
}

public struct InspectorMCPInspectResult: Codable, Equatable {
    public let handle: String
    public let presented: Bool

    public init(handle: String, presented: Bool) {
        self.handle = handle
        self.presented = presented
    }
}

public struct InspectorMCPTapResult: Codable, Equatable {
    public let handle: String
    public let dispatched: Bool

    public init(handle: String, dispatched: Bool) {
        self.handle = handle
        self.dispatched = dispatched
    }
}

public struct InspectorMCPEditablePropertyPath: Codable, Equatable {
    public let panel: InspectorMCPEditablePanel
    public let section: Int
    public let row: Int
    public let slot: InspectorMCPEditablePropertySlot
    public let index: Int

    public init(panel: InspectorMCPEditablePanel, section: Int, row: Int, slot: InspectorMCPEditablePropertySlot, index: Int) {
        self.panel = panel
        self.section = section
        self.row = row
        self.slot = slot
        self.index = index
    }
}

public struct InspectorMCPEditableProperty: Codable, Equatable {
    public let propertyRef: String
    public let path: InspectorMCPEditablePropertyPath
    public let title: String
    public let kind: InspectorMCPEditablePropertyKind
    public let editable: Bool
    public let boolValue: Bool?
    public let numberValue: Double?
    public let stringValue: String?
    public let selectionIndex: Int?
    public let minimum: Double?
    public let maximum: Double?
    public let step: Double?
    public let isDecimal: Bool?
    public let options: [String]?
    public let nullable: Bool

    public init(
        propertyRef: String,
        path: InspectorMCPEditablePropertyPath,
        title: String,
        kind: InspectorMCPEditablePropertyKind,
        editable: Bool,
        boolValue: Bool? = nil,
        numberValue: Double? = nil,
        stringValue: String? = nil,
        selectionIndex: Int? = nil,
        minimum: Double? = nil,
        maximum: Double? = nil,
        step: Double? = nil,
        isDecimal: Bool? = nil,
        options: [String]? = nil,
        nullable: Bool
    ) {
        self.propertyRef = propertyRef
        self.path = path
        self.title = title
        self.kind = kind
        self.editable = editable
        self.boolValue = boolValue
        self.numberValue = numberValue
        self.stringValue = stringValue
        self.selectionIndex = selectionIndex
        self.minimum = minimum
        self.maximum = maximum
        self.step = step
        self.isDecimal = isDecimal
        self.options = options
        self.nullable = nullable
    }
}

public struct InspectorMCPEditablePropertyRow: Codable, Equatable {
    public let title: String
    public let subtitle: String?
    public let properties: [InspectorMCPEditableProperty]

    public init(title: String, subtitle: String? = nil, properties: [InspectorMCPEditableProperty]) {
        self.title = title
        self.subtitle = subtitle
        self.properties = properties
    }
}

public struct InspectorMCPEditablePropertySection: Codable, Equatable {
    public let title: String?
    public let rows: [InspectorMCPEditablePropertyRow]

    public init(title: String? = nil, rows: [InspectorMCPEditablePropertyRow]) {
        self.title = title
        self.rows = rows
    }
}

public struct InspectorMCPPropertyListResult: Codable, Equatable {
    public let handle: String
    public let expiresAt: Date
    public let panel: InspectorMCPEditablePanel
    public let sections: [InspectorMCPEditablePropertySection]

    public init(handle: String, expiresAt: Date, panel: InspectorMCPEditablePanel, sections: [InspectorMCPEditablePropertySection]) {
        self.handle = handle
        self.expiresAt = expiresAt
        self.panel = panel
        self.sections = sections
    }
}

public struct InspectorMCPSetPropertyResult: Codable, Equatable {
    public let propertyRef: String
    public let applied: Bool
    public let refreshRecommended: Bool

    public init(propertyRef: String, applied: Bool, refreshRecommended: Bool) {
        self.propertyRef = propertyRef
        self.applied = applied
        self.refreshRecommended = refreshRecommended
    }
}

public struct InspectorMCPActionDescriptor: Codable, Equatable {
    public let actionRef: String
    public let title: String
    public let kind: InspectorMCPActionKind

    public init(actionRef: String, title: String, kind: InspectorMCPActionKind) {
        self.actionRef = actionRef
        self.title = title
        self.kind = kind
    }
}

public struct InspectorMCPActionListResult: Codable, Equatable {
    public let handle: String
    public let expiresAt: Date
    public let actions: [InspectorMCPActionDescriptor]

    public init(handle: String, expiresAt: Date, actions: [InspectorMCPActionDescriptor]) {
        self.handle = handle
        self.expiresAt = expiresAt
        self.actions = actions
    }
}

public struct InspectorMCPPerformActionResult: Codable, Equatable {
    public let actionRef: String
    public let performed: Bool
    public let refreshRecommended: Bool

    public init(actionRef: String, performed: Bool, refreshRecommended: Bool) {
        self.actionRef = actionRef
        self.performed = performed
        self.refreshRecommended = refreshRecommended
    }
}

public struct InspectorMCPAssertPropertyResult: Codable, Equatable {
    public let handle: String
    public let property: InspectorMCPAssertableProperty
    public let passed: Bool
    public let actualBool: Bool?
    public let actualNumber: Double?
    public let actualString: String?
    public let message: String

    public init(
        handle: String,
        property: InspectorMCPAssertableProperty,
        passed: Bool,
        actualBool: Bool? = nil,
        actualNumber: Double? = nil,
        actualString: String? = nil,
        message: String
    ) {
        self.handle = handle
        self.property = property
        self.passed = passed
        self.actualBool = actualBool
        self.actualNumber = actualNumber
        self.actualString = actualString
        self.message = message
    }
}

public struct InspectorMCPAssertVisibleResult: Codable, Equatable {
    public let handle: String
    public let passed: Bool
    public let isHidden: Bool
    public let message: String

    public init(handle: String, passed: Bool, isHidden: Bool, message: String) {
        self.handle = handle
        self.passed = passed
        self.isHidden = isHidden
        self.message = message
    }
}

public struct InspectorMCPAssertHierarchyContainsResult: Codable, Equatable {
    public let passed: Bool
    public let matchCount: Int
    public let minimumCount: Int
    public let message: String

    public init(passed: Bool, matchCount: Int, minimumCount: Int, message: String) {
        self.passed = passed
        self.matchCount = matchCount
        self.minimumCount = minimumCount
        self.message = message
    }
}

public enum InspectorMCPStateDiffKind: String, Codable {
    case added
    case removed
    case changed
}

public struct InspectorMCPCapturedState: Codable, Equatable {
    public let stateRef: String
    public let createdAt: Date
    public let nodeCount: Int

    public init(stateRef: String, createdAt: Date, nodeCount: Int) {
        self.stateRef = stateRef
        self.createdAt = createdAt
        self.nodeCount = nodeCount
    }
}

public struct InspectorMCPStateDiffEntry: Codable, Equatable {
    public let signature: String
    public let kind: InspectorMCPStateDiffKind
    public let className: String
    public let elementName: String
    public let accessibilityIdentifier: String?

    public init(signature: String, kind: InspectorMCPStateDiffKind, className: String, elementName: String, accessibilityIdentifier: String?) {
        self.signature = signature
        self.kind = kind
        self.className = className
        self.elementName = elementName
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

public struct InspectorMCPStateDiff: Codable, Equatable {
    public let beforeRef: String
    public let afterRef: String
    public let addedCount: Int
    public let removedCount: Int
    public let changedCount: Int
    public let entries: [InspectorMCPStateDiffEntry]

    public init(beforeRef: String, afterRef: String, addedCount: Int, removedCount: Int, changedCount: Int, entries: [InspectorMCPStateDiffEntry]) {
        self.beforeRef = beforeRef
        self.afterRef = afterRef
        self.addedCount = addedCount
        self.removedCount = removedCount
        self.changedCount = changedCount
        self.entries = entries
    }
}

public struct InspectorMCPSavedScenario: Codable, Equatable {
    public let name: String
    public let createdAt: Date
    public let nodeCount: Int

    public init(name: String, createdAt: Date, nodeCount: Int) {
        self.name = name
        self.createdAt = createdAt
        self.nodeCount = nodeCount
    }
}

public struct InspectorMCPScenarioListResult: Codable, Equatable {
    public let scenarios: [InspectorMCPSavedScenario]

    public init(scenarios: [InspectorMCPSavedScenario]) {
        self.scenarios = scenarios
    }
}

public struct InspectorMCPScenarioDiff: Codable, Equatable {
    public let name: String
    public let addedCount: Int
    public let removedCount: Int
    public let changedCount: Int
    public let entries: [InspectorMCPStateDiffEntry]

    public init(name: String, addedCount: Int, removedCount: Int, changedCount: Int, entries: [InspectorMCPStateDiffEntry]) {
        self.name = name
        self.addedCount = addedCount
        self.removedCount = removedCount
        self.changedCount = changedCount
        self.entries = entries
    }
}

public struct InspectorMCPLayerState: Codable, Equatable {
    public let name: String
    public let displayName: String
    public let active: Bool

    public init(name: String, displayName: String, active: Bool) {
        self.name = name
        self.displayName = displayName
        self.active = active
    }
}

public struct InspectorMCPLayersResult: Codable, Equatable {
    public let layers: [InspectorMCPLayerState]

    public init(layers: [InspectorMCPLayerState]) {
        self.layers = layers
    }
}

public struct InspectorMCPToggleLayerRequest: Codable, Equatable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct InspectorMCPToggleLayerResult: Codable, Equatable {
    public let name: String
    public let active: Bool

    public init(name: String, active: Bool) {
        self.name = name
        self.active = active
    }
}

public enum InspectorMCPSnapshotUnavailableReason: String, Codable {
    case lostConnection
    case noWindow
    case frameIsEmpty
    case isHidden
    case captureFailed
    case runtimeSnapshotUnavailable
}

public enum InspectorMCPWireErrorCode: String, Codable {
    case disabled
    case notStarted
    case staleHandle
    case unresolvedSemanticReference
    case ambiguousSemanticReference
    case stalePropertyReference
    case staleActionReference
    case staleStateReference
    case unknownScenario
    case snapshotUnavailable
    case unsupportedTarget
    case invalidPropertyValue
    case internalFailure
}

public enum InspectorMCPTransportErrorDetails: Equatable {
    case empty
    case snapshotUnavailable(reason: InspectorMCPSnapshotUnavailableReason)
    case internalFailure(message: String)
}

extension InspectorMCPTransportErrorDetails: Codable {
    private enum CodingKeys: String, CodingKey {
        case reason
        case message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let reason = try container.decodeIfPresent(InspectorMCPSnapshotUnavailableReason.self, forKey: .reason) {
            self = .snapshotUnavailable(reason: reason)
            return
        }

        if let message = try container.decodeIfPresent(String.self, forKey: .message) {
            self = .internalFailure(message: message)
            return
        }

        self = .empty
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .empty:
            break
        case let .snapshotUnavailable(reason):
            try container.encode(reason, forKey: .reason)
        case let .internalFailure(message):
            try container.encode(message, forKey: .message)
        }
    }
}

public struct InspectorMCPTransportError: Codable, Equatable, Error {
    public let code: InspectorMCPWireErrorCode
    public let message: String
    public let details: InspectorMCPTransportErrorDetails

    public init(
        code: InspectorMCPWireErrorCode,
        message: String,
        details: InspectorMCPTransportErrorDetails
    ) {
        self.code = code
        self.message = message
        self.details = details
    }
}

public struct InspectorMCPSuccessEnvelope<Result: Codable & Equatable>: Codable, Equatable {
    public let ok: Bool
    public let result: Result

    public init(result: Result) {
        self.ok = true
        self.result = result
    }
}

public struct InspectorMCPFailureEnvelope: Codable, Equatable {
    public let ok: Bool
    public let error: InspectorMCPTransportError

    public init(error: InspectorMCPTransportError) {
        self.ok = false
        self.error = error
    }
}
