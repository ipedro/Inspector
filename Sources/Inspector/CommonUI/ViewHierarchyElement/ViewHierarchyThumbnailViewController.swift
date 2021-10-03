//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

struct ViewHierarchyThumbnailViewModel: ViewHierarchyElementDescriptionViewModelProtocol {
    let element: ViewHierarchyElement

    // MARK: - ViewHierarchyReferenceDetailViewModelProtocol

    var isCollapsed: Bool = false

    var automaticallyAdjustIndentation: Bool { false }

    var iconImage: UIImage? { element.iconImage }

    var title: String? { element.elementName }

    var titleFont: UIFont { ElementInspector.appearance.titleFont(forRelativeDepth: .zero) }

    var subtitle: String? { element.elementDescription }

    var subtitleFont: UIFont { ElementInspector.appearance.font(forRelativeDepth: .zero) }

    var isContainer: Bool { false }

    var isCollapseButtonEnabled: Bool { false }

    var hideCollapseButton: Bool { true }

    var isHidden: Bool { false }

    var relativeDepth: Int { .zero }
}

final class ViewHierarchyPreviewController: UIViewController {
    let element: ViewHierarchyElement

    init(with element: ViewHierarchyElement) {
        self.element = element
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private(set) lazy var viewCode = BaseView().then {
        $0.installView($0.contentView, priority: .required)
        $0.backgroundColor = $0.colorStyle.highlightBackgroundColor
    }

    private(set) lazy var elementDescriptionView = ViewHierarchyElementDescriptionView().then {
        $0.viewModel = element
    }

    private(set) lazy var separatorView = SeparatorView(style: .hard)

    private(set) lazy var thumbnailView = LiveViewHierarchyElementThumbnailView(with: element)

    override func loadView() {
        view = viewCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewCode.contentView.addArrangedSubviews(elementDescriptionView, separatorView, thumbnailView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let size = view.systemLayoutSizeFitting(
            view.frame.size,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        preferredContentSize = size
    }
}
