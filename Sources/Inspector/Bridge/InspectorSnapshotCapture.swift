#if canImport(UIKit)
import UIKit

enum InspectorSnapshotCaptureFailure: Error, Equatable {
    case lostConnection
    case noWindow
    case frameIsEmpty(CGRect)
    case isHidden
    case captureFailed
}

enum InspectorSnapshotCapture {
    static func snapshotView(
        for reference: ViewHierarchyElementReference,
        afterScreenUpdates: Bool
    ) -> Result<UIView, InspectorSnapshotCaptureFailure> {
        guard let referenceView = reference._underlyingView else {
            return .failure(InspectorSnapshotCaptureFailure.lostConnection)
        }

        if referenceView.isAssociatedToWindow == false {
            return .failure(InspectorSnapshotCaptureFailure.noWindow)
        }

        guard referenceView.frame.isEmpty == false, referenceView.frame != .zero else {
            return .failure(InspectorSnapshotCaptureFailure.frameIsEmpty(referenceView.frame))
        }

        guard referenceView.isHidden == false else {
            return .failure(InspectorSnapshotCaptureFailure.isHidden)
        }

        guard let snapshotView = referenceView.snapshotView(afterScreenUpdates: afterScreenUpdates) else {
            return .failure(InspectorSnapshotCaptureFailure.captureFailed)
        }

        return .success(snapshotView)
    }
}
#endif
