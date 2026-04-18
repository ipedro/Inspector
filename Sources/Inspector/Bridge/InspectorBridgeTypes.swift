#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
import Foundation
import UIKit

public enum InspectorBridgeNodeKind: String, Codable {
    case window
    case viewController
    case view
}

public struct InspectorBridgeHandle: Hashable, Codable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct InspectorBridgeQueryRequest: Hashable, Codable {
    public var nodeKind: InspectorBridgeNodeKind?
    public var classNameContains: String?
    public var displayNameContains: String?
    public var elementNameContains: String?
    public var accessibilityIdentifierEquals: String?
    public var isInternalView: Bool?
    public var isSystemContainer: Bool?

    public init(
        nodeKind: InspectorBridgeNodeKind? = nil,
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

public struct InspectorBridgeNode: Hashable, Codable {
    public let handle: InspectorBridgeHandle
    public let nodeKind: InspectorBridgeNodeKind
    public let backingObjectType: String
    public let className: String
    public let displayName: String
    public let elementName: String
    public let accessibilityIdentifier: String?
    public let frame: CGRect
    public let isHidden: Bool
    public let isUserInteractionEnabled: Bool
    public let isInternalView: Bool
    public let isSystemContainer: Bool
    public let depth: Int
    public let parentHandle: InspectorBridgeHandle?
    public let childHandles: [InspectorBridgeHandle]
    public let childCount: Int
}

public struct InspectorBridgeQueryResponse: Hashable, Codable {
    public let expiresAt: Date
    public let nodes: [InspectorBridgeNode]

    public init(expiresAt: Date, nodes: [InspectorBridgeNode]) {
        self.expiresAt = expiresAt
        self.nodes = nodes
    }
}

public enum InspectorBridgeEditablePanel: String, Codable, Hashable {
    case identity
    case attributes
    case size
}

public enum InspectorBridgeEditablePropertyKind: String, Codable {
    case toggle
    case stepper
    case textField
    case textView
    case optionsList
    case textButtonGroup
    case imageButtonGroup
}

public enum InspectorBridgeEditablePropertySlot: String, Codable {
    case property
    case titleAccessory
}

public struct InspectorBridgeEditablePropertyPath: Hashable, Codable {
    public let panel: InspectorBridgeEditablePanel
    public let section: Int
    public let row: Int
    public let slot: InspectorBridgeEditablePropertySlot
    public let index: Int
}

public struct InspectorBridgeEditablePropertyDescriptor: Hashable, Codable {
    public let propertyRef: String
    public let path: InspectorBridgeEditablePropertyPath
    public let title: String
    public let kind: InspectorBridgeEditablePropertyKind
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
}

public struct InspectorBridgeEditablePropertyRow: Hashable, Codable {
    public let title: String
    public let subtitle: String?
    public let properties: [InspectorBridgeEditablePropertyDescriptor]
}

public struct InspectorBridgeEditablePropertySection: Hashable, Codable {
    public let title: String?
    public let rows: [InspectorBridgeEditablePropertyRow]
}

public struct InspectorBridgePropertyListResponse: Hashable, Codable {
    public let handle: InspectorBridgeHandle
    public let expiresAt: Date
    public let panel: InspectorBridgeEditablePanel
    public let sections: [InspectorBridgeEditablePropertySection]
}

public enum InspectorBridgePropertyMutationValue: Hashable, Codable {
    case bool(Bool)
    case number(Double)
    case string(String?)
    case selection(Int?)
}

public struct InspectorBridgePropertyMutationResult: Hashable, Codable {
    public let propertyRef: String
    public let applied: Bool
    public let refreshRecommended: Bool
}

public enum InspectorBridgeActionKind: String, Codable, Hashable {
    case inspect
    case showHighlight
    case hideHighlight
}

public enum InspectorBridgeAssertableProperty: String, Codable, Hashable {
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

public struct InspectorBridgeActionDescriptor: Hashable, Codable {
    public let actionRef: String
    public let title: String
    public let kind: InspectorBridgeActionKind
}

public struct InspectorBridgeActionListResponse: Hashable, Codable {
    public let handle: InspectorBridgeHandle
    public let expiresAt: Date
    public let actions: [InspectorBridgeActionDescriptor]
}

public struct InspectorBridgeActionResult: Hashable, Codable {
    public let actionRef: String
    public let performed: Bool
    public let refreshRecommended: Bool
}

public enum InspectorBridgeAssertionValue: Hashable, Codable {
    case bool(Bool)
    case number(Double)
    case string(String?)
}

public struct InspectorBridgeAssertPropertyResult: Hashable, Codable {
    public let handle: InspectorBridgeHandle
    public let property: InspectorBridgeAssertableProperty
    public let passed: Bool
    public let actualBool: Bool?
    public let actualNumber: Double?
    public let actualString: String?
    public let message: String
}

public struct InspectorBridgeAssertVisibleResult: Hashable, Codable {
    public let handle: InspectorBridgeHandle
    public let passed: Bool
    public let isHidden: Bool
    public let message: String
}

public struct InspectorBridgeAssertHierarchyContainsResult: Hashable, Codable {
    public let passed: Bool
    public let matchCount: Int
    public let minimumCount: Int
    public let message: String
}

public struct InspectorBridgeCapturedNodeState: Hashable, Codable {
    public let signature: String
    public let nodeKind: InspectorBridgeNodeKind
    public let className: String
    public let elementName: String
    public let accessibilityIdentifier: String?
    public let isHidden: Bool
    public let isUserInteractionEnabled: Bool
    public let isInternalView: Bool
    public let isSystemContainer: Bool
    public let childCount: Int
    public let depth: Int
}

public struct InspectorBridgeStateCapture: Hashable, Codable {
    public let stateRef: String
    public let createdAt: Date
    public let nodeCount: Int
}

public enum InspectorBridgeStateDiffKind: String, Codable, Hashable {
    case added
    case removed
    case changed
}

public struct InspectorBridgeStateDiffEntry: Hashable, Codable {
    public let signature: String
    public let kind: InspectorBridgeStateDiffKind
    public let className: String
    public let elementName: String
    public let accessibilityIdentifier: String?
}

public struct InspectorBridgeStateDiff: Hashable, Codable {
    public let beforeRef: String
    public let afterRef: String
    public let addedCount: Int
    public let removedCount: Int
    public let changedCount: Int
    public let entries: [InspectorBridgeStateDiffEntry]
}

public struct InspectorBridgeSavedScenario: Hashable, Codable {
    public let name: String
    public let createdAt: Date
    public let nodeCount: Int
}

public struct InspectorBridgeScenarioDiff: Hashable, Codable {
    public let name: String
    public let addedCount: Int
    public let removedCount: Int
    public let changedCount: Int
    public let entries: [InspectorBridgeStateDiffEntry]
}

public struct InspectorBridgeLayerState: Hashable, Codable {
    public let name: String
    public let displayName: String
    public let active: Bool

    public init(name: String, displayName: String, active: Bool) {
        self.name = name
        self.displayName = displayName
        self.active = active
    }
}

public struct InspectorBridgeSnapshotArtifact: Hashable, Codable {
    public let handle: InspectorBridgeHandle
    public let pngURL: URL
    public let size: CGSize
    public let deviceScale: CGFloat
    public let createdAt: Date

    public init(
        handle: InspectorBridgeHandle,
        pngURL: URL,
        size: CGSize,
        deviceScale: CGFloat,
        createdAt: Date
    ) {
        self.handle = handle
        self.pngURL = pngURL
        self.size = size
        self.deviceScale = deviceScale
        self.createdAt = createdAt
    }
}

public enum InspectorBridgeSnapshotUnavailableReason: String, Codable {
    case lostConnection
    case noWindow
    case frameIsEmpty
    case isHidden
    case captureFailed
    case runtimeSnapshotUnavailable
}

public enum InspectorBridgeError: Error, Hashable, Codable {
    case disabled
    case notStarted
    case staleHandle
    case stalePropertyReference
    case staleActionReference
    case staleStateReference
    case unknownScenario
    case snapshotUnavailable(InspectorBridgeSnapshotUnavailableReason)
    case unsupportedTarget
    case invalidPropertyValue(String)
    case internalFailure(String)
}
#endif
