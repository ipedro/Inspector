#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
import UIKit

public enum InspectorBridge {
    public static func query(_ request: InspectorBridgeQueryRequest = .init()) throws -> InspectorBridgeQueryResponse {
        try Inspector.bridgeQuery(request)
    }

    public static func resolve(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeNode {
        try Inspector.bridgeResolve(handle)
    }

    public static func snapshot(
        _ handle: InspectorBridgeHandle,
        afterScreenUpdates: Bool = true
    ) throws -> InspectorBridgeSnapshotArtifact {
        try Inspector.bridgeSnapshot(handle, afterScreenUpdates: afterScreenUpdates)
    }
}
#endif
