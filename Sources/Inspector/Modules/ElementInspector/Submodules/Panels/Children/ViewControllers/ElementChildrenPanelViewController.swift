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

protocol ElementChildrenPanelViewControllerDelegate: OperationQueueManagerProtocol {
    func elementChildrenPanelViewController(_ viewController: ElementChildrenPanelViewController,
                                            didSelect reference: ViewHierarchyReference,
                                            with preferredPanel: ElementInspectorPanel?,
                                            from rootReference: ViewHierarchyReference)

    func elementChildrenPanelViewController(_ viewController: ElementChildrenPanelViewController,
                                            previewFor reference: ViewHierarchyReference) -> UIViewController?
}

final class ElementChildrenPanelViewController: ElementInspectorPanelViewController {
    // MARK: - Properties

    weak var delegate: ElementChildrenPanelViewControllerDelegate?

    private var needsSetup = true

    private(set) lazy var viewCode = ElementChildrenPanelViewCode(
        frame: CGRect(
            origin: .zero,
            size: ElementInspector.appearance.panelPreferredCompressedSize
        )
    ).then {
        $0.tableView.register(ElementChildrenPanelTableViewCodeCell.self)
        $0.tableView.activateAccessoryButtonKeyCommandOptions = [.discoverabilityTitle(title: "Inspect", key: .key("i"))]
        $0.tableView.dataSource = self
        $0.tableView.delegate = self
    }

    let viewModel: ElementChildrenPanelViewModelProtocol

    // MARK: - Init

    init(viewModel: ElementChildrenPanelViewModelProtocol) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = viewCode
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewCode.tableView.becomeFirstResponder()
    }

    func reloadData() {
        viewModel.reloadIcons()
        viewCode.tableView.reloadData()
    }

    override func calculatePreferredContentSize() -> CGSize {
        let contentHeight = viewCode.tableView.estimatedRowHeight * CGFloat(viewModel.numberOfRows)
        let contentInset = viewCode.tableView.contentInset

        return CGSize(
            width: ElementInspector.appearance.panelPreferredCompressedSize.width,
            height: contentHeight + contentInset.top + contentInset.bottom
        )
    }
}
