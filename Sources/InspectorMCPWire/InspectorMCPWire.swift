import Foundation

public enum InspectorMCPBridgeEndpoint {
    public static let host = "127.0.0.1"
    public static let port: UInt16 = 49_321
    public static let healthPath = "/health"
    public static let queryPath = "/query"
    public static let resolvePath = "/resolve"
    public static let snapshotPath = "/snapshot"
    public static let inspectPath = "/inspect"
    public static let tapPath = "/tap"
    public static let propertiesPath = "/properties"
    public static let setPropertyPath = "/set-property"
    public static let layersPath = "/layers"
    public static let toggleLayerPath = "/toggle-layer"
    public static let baseURL = URL(string: "http://\(host):\(port)")!
}

public enum InspectorMCPOperation: String, Codable, CaseIterable {
    case query
    case resolve
    case snapshot
    case inspect
    case tap
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
    public let bundleIdentifier: String?
    public let operations: [InspectorMCPOperation]
    public let apiVersion: Int?

    public init(
        status: InspectorMCPHealthStatus,
        bridgeEnabled: Bool,
        inspectorStarted: Bool,
        bundleIdentifier: String?,
        operations: [InspectorMCPOperation],
        apiVersion: Int? = nil
    ) {
        self.status = status
        self.bridgeEnabled = bridgeEnabled
        self.inspectorStarted = inspectorStarted
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

    public init(
        nodeKind: InspectorMCPNodeKind? = nil,
        classNameContains: String? = nil,
        displayNameContains: String? = nil,
        elementNameContains: String? = nil,
        accessibilityIdentifierEquals: String? = nil
    ) {
        self.nodeKind = nodeKind
        self.classNameContains = classNameContains
        self.displayNameContains = displayNameContains
        self.elementNameContains = elementNameContains
        self.accessibilityIdentifierEquals = accessibilityIdentifierEquals
    }
}

public struct InspectorMCPResolveRequest: Codable, Equatable {
    public let handle: String

    public init(handle: String) {
        self.handle = handle
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

public struct InspectorMCPNode: Codable, Equatable {
    public let handle: String
    public let nodeKind: InspectorMCPNodeKind
    public let backingObjectType: String
    public let className: String
    public let displayName: String
    public let elementName: String
    public let accessibilityIdentifier: String?
    public let frame: InspectorMCPFrame
    public let isHidden: Bool
    public let isUserInteractionEnabled: Bool
    public let depth: Int
    public let parentHandle: String?
    public let childHandles: [String]
    public let childCount: Int

    public init(
        handle: String,
        nodeKind: InspectorMCPNodeKind,
        backingObjectType: String,
        className: String,
        displayName: String,
        elementName: String,
        accessibilityIdentifier: String?,
        frame: InspectorMCPFrame,
        isHidden: Bool,
        isUserInteractionEnabled: Bool,
        depth: Int,
        parentHandle: String?,
        childHandles: [String],
        childCount: Int
    ) {
        self.handle = handle
        self.nodeKind = nodeKind
        self.backingObjectType = backingObjectType
        self.className = className
        self.displayName = displayName
        self.elementName = elementName
        self.accessibilityIdentifier = accessibilityIdentifier
        self.frame = frame
        self.isHidden = isHidden
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.depth = depth
        self.parentHandle = parentHandle
        self.childHandles = childHandles
        self.childCount = childCount
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
    case stalePropertyReference
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
