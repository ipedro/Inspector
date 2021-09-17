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

struct ViewHierarchyThumbnailViewModel: ViewHierarchyReferenceDetailViewModelProtocol {
    let reference: ViewHierarchyReference
    let snapshot: ViewHierarchySnapshot

    // MARK: - ViewHierarchyReferenceDetailViewModelProtocol

    var isCollapsed: Bool = false

    var automaticallyAdjustIndentation: Bool { false }

    var thumbnailImage: UIImage? { snapshot.elementLibraries.icon(for: reference.rootView)}

    var title: String { reference.accessibilityIdentifier ?? reference.className }

    var titleFont: UIFont { ElementInspector.appearance.titleFont(forRelativeDepth: .zero) }

    var subtitle: String { reference.elementDescription }

    var isContainer: Bool { false }

    var showCollapseButton: Bool { false }

    var isHidden: Bool { false }

    var relativeDepth: Int { .zero }
}

final class ViewHierarchyThumbnailViewController: UIViewController {

    let viewModel: ViewHierarchyThumbnailViewModel

    init(viewModel: ViewHierarchyThumbnailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private(set) lazy var viewCode = BaseView().then {
        $0.backgroundColor = $0.colorStyle.highlightBackgroundColor
    }

    private(set) lazy var referenceDetailView = ViewHierarchyReferenceDetailView().then {
        $0.viewModel = viewModel
    }

    private(set) lazy var thumbnailView = ViewHierarchyReferenceThumbnailView(
        frame: .zero,
        reference: viewModel.reference
    )

    override func loadView() {
        view = viewCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewCode.contentView.addArrangedSubviews(referenceDetailView, thumbnailView)

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

        preferredContentSize = CGSize(
            width: size.width + ElementInspector.appearance.horizontalMargins * 2,
            height: size.height + ElementInspector.appearance.verticalMargins * 2
        )
    }
}

private extension CGSize {
    var aspectRatio: CGFloat { width / height }
}
