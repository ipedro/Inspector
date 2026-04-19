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

public struct InspectorPropertyRuntimePresentation {
    public var emptyTitle: String?
    public var selectionOptionIcons: [UIImage?]?
    public var selectionImages: [UIImage]?

    public init(
        emptyTitle: String? = nil,
        selectionOptionIcons: [UIImage?]? = nil,
        selectionImages: [UIImage]? = nil
    ) {
        self.emptyTitle = emptyTitle
        self.selectionOptionIcons = selectionOptionIcons
        self.selectionImages = selectionImages
    }
}

public struct InspectorPropertyBinding {
    public let descriptor: InspectorContract.InspectorPropertyDescriptor
    public let read: @MainActor () -> InspectorValue
    public let write: (@MainActor (InspectorValue) -> Void)?
    public let refreshHint: InspectorRefreshHint
    public let runtimePresentation: InspectorPropertyRuntimePresentation?

    public init(
        descriptor: InspectorContract.InspectorPropertyDescriptor,
        read: @escaping @MainActor () -> InspectorValue,
        write: (@MainActor (InspectorValue) -> Void)? = nil,
        refreshHint: InspectorRefreshHint = .reloadInspector,
        runtimePresentation: InspectorPropertyRuntimePresentation? = nil
    ) {
        self.descriptor = descriptor
        self.read = read
        self.write = write
        self.refreshHint = refreshHint
        self.runtimePresentation = runtimePresentation
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

public extension InspectorPropertyBinding {
    func currentValue() -> InspectorValue {
        readValue()
    }

    func apply(_ value: InspectorValue) {
        writeValue(value)
    }

    fileprivate func writeValue(_ value: InspectorValue) {
        guard let write else { return }

        if Thread.isMainThread {
            MainActor.assumeIsolated { write(value) }
            return
        }

        DispatchQueue.main.sync {
            MainActor.assumeIsolated { write(value) }
        }
    }

    fileprivate func readValue() -> InspectorValue {
        if Thread.isMainThread {
            return MainActor.assumeIsolated { read() }
        }

        return DispatchQueue.main.sync {
            MainActor.assumeIsolated { read() }
        }
    }

    fileprivate var axis: NSLayoutConstraint.Axis {
        switch descriptor.presentation?.axis {
        case .horizontal:
            .horizontal
        case .vertical:
            .vertical
        case .none:
            .vertical
        }
    }
}

private extension NSLayoutConstraint.Axis {
    var inspectorAxis: InspectorContract.InspectorAxis {
        switch self {
        case .horizontal:
            .horizontal
        case .vertical:
            .vertical
        @unknown default:
            .vertical
        }
    }
}
