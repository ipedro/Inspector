import UIKit

public protocol InspectorElementFormItemViewDelegate: AnyObject {
    func inspectorElementFormItemView(_ item: InspectorElementSectionView,
                                      willChangeFrom oldState: InspectorElementSectionState?,
                                      to newState: InspectorElementSectionState)
}

public protocol InspectorElementSectionView: UIView {
    var delegate: InspectorElementFormItemViewDelegate? { get set }

    /// Optional section title.
    var title: String? { get set }

    /// Optional section subtitle.
    var subtitle: String? { get set }

    /// Defines the section separator appearance.
    var separatorStyle: InspectorElementItemSeparatorStyle { get set }

    /// The current state of the section.
    var state: InspectorElementSectionState { get set }

    /// When this method is called is your view's responsibility to add the given form views to it's hiearchy.
    func addFormViews(_ formViews: [UIView])

    /// When this method is called is your view's responsibility to add the given form views to it's hiearchy.
    func addTitleAccessoryView(_ titleAccessoryView: UIView?)

    /// Create and return a container view that conforms to the `InspectorElementFormSectionView` protocol.
    static func makeItemView(with inititalState: InspectorElementSectionState) -> InspectorElementSectionView
}
