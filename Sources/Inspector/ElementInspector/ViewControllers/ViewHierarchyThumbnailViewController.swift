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

struct ViewHierarchyThumbnailViewModel: ViewHierarchyReferenceSummaryViewModelProtocol {

    let reference: ViewHierarchyReference

    // MARK: - ViewHierarchyReferenceDetailViewModelProtocol

    var isCollapsed: Bool = false

    var automaticallyAdjustIndentation: Bool { false }

    var iconImage: UIImage? { reference.iconImage }

    var title: String { reference.elementName }

    var titleFont: UIFont { ElementInspector.appearance.titleFont(forRelativeDepth: .zero) }

    var subtitle: String { reference.elementDescription }

    var subtitleFont: UIFont { ElementInspector.appearance.font(forRelativeDepth: .zero) }

    var isContainer: Bool { false }

    var showCollapseButton: Bool { false }

    var isHidden: Bool { false }

    var relativeDepth: Int { .zero }
}

final class ViewHierarchyPreviewViewController: UIViewController {
    let reference: ViewHierarchyReference

    init(for reference: ViewHierarchyReference) {
        self.reference = reference
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

    private(set) lazy var referenceSummaryView = ViewHierarchyReferenceSummaryView().then {
        $0.viewModel = reference
    }

    private(set) lazy var thumbnailView = ViewHierarchyReferenceThumbnailView(
        frame: .zero,
        reference: reference
    )

    override func loadView() {
        view = viewCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewCode.contentView.addArrangedSubviews(referenceSummaryView, thumbnailView)

        thumbnailView.updateViews(afterScreenUpdates: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        thumbnailView.updateViews(afterScreenUpdates: true)
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
