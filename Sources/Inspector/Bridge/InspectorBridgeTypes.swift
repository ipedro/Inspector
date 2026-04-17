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

    public init(
        nodeKind: InspectorBridgeNodeKind? = nil,
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
    case snapshotUnavailable(InspectorBridgeSnapshotUnavailableReason)
    case unsupportedTarget
    case internalFailure(String)
}
#endif
