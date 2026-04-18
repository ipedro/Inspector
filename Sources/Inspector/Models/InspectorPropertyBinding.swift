import InspectorContract
import UIKit

public enum InspectorValue {
    case bool(Bool)
    case number(Double)
    case string(String?)
    case selection(Int?)
    case color(UIColor?)
    case image(UIImage?)
    case preview(UIView)
    case rect(CGRect)
    case point(CGPoint)
    case size(CGSize)
    case offset(UIOffset)
    case edgeInsets(UIEdgeInsets)
    case directionalEdgeInsets(NSDirectionalEdgeInsets)
    case none
}

public enum InspectorRefreshHint: Hashable {
    case none
    case reloadSection
    case reloadInspector
}

public struct InspectorPropertyBinding {
    public let descriptor: InspectorContract.InspectorPropertyDescriptor
    public let read: @MainActor () -> InspectorValue
    public let write: (@MainActor (InspectorValue) -> Void)?
    public let refreshHint: InspectorRefreshHint

    public init(
        descriptor: InspectorContract.InspectorPropertyDescriptor,
        read: @escaping @MainActor () -> InspectorValue,
        write: (@MainActor (InspectorValue) -> Void)? = nil,
        refreshHint: InspectorRefreshHint = .reloadInspector
    ) {
        self.descriptor = descriptor
        self.read = read
        self.write = write
        self.refreshHint = refreshHint
    }
}

public struct InspectorSectionBinding {
    public let descriptor: InspectorContract.InspectorSectionDescriptor
    public let fields: [InspectorPropertyBinding]

    public init(
        descriptor: InspectorContract.InspectorSectionDescriptor,
        fields: [InspectorPropertyBinding]
    ) {
        self.descriptor = descriptor
        self.fields = fields
    }
}
