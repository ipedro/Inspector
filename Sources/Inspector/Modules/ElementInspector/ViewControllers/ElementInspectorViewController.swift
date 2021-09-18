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

protocol ElementInspectorPanelViewControllerDelegate: OperationQueueManagerProtocol {
    func elementInspectorFormPanelViewController(_ viewController: ElementInspectorViewController,
                                        viewControllerFor panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController

    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController)
}

#if swift(>=5.0)
@available(iOS 13.0, *)
extension ElementInspectorViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: {
                ViewHierarchyThumbnailViewController(
                    viewModel: .init(
                        reference: self.viewModel.reference,
                        snapshot: self.viewModel.snapshot
                    )
                )
            },
            actionProvider: { [weak self] _ in
                guard let self = self else { return nil }

                return UIMenu(
                    title: self.viewModel.title,
                    image: self.viewModel.thumbnailImage,
                    children: [
                        UIMenu(
                            title: "Copy",
                            image: .copySymbol,
                            options: .displayInline,
                            children: [
                                UIAction.copyAction(
                                    title: "Copy Class Name",
                                    stringProvider: { [weak self] in self?.viewModel.reference.className }
                                ),
                                UIAction.copyAction(
                                    title: "Copy Description",
                                    stringProvider: { [weak self] in self?.viewModel.reference.elementDescription }
                                )
                            ]
                        )
                    ]
                )
            }
        )
    }
}
#endif

final class ElementInspectorViewController: UIViewController {
    weak var delegate: ElementInspectorPanelViewControllerDelegate?

    private var viewModel: ElementInspectorViewModelProtocol! {
        didSet {
            title = viewModel.reference.elementName
            viewCode.referenceSummaryView.viewModel = viewModel

            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                let interaction = UIContextMenuInteraction(delegate: self)
                viewCode.referenceSummaryView.addInteraction(interaction)
            }
            #endif
        }
    }

    override var preferredContentSize: CGSize {
        didSet {
            Console.log(classForCoder, #function, preferredContentSize)
        }
    }

    private var presentedPanelViewController: UIViewController? {
        didSet {
            viewCode.emptyLabel.isHidden = presentedPanelViewController != nil

            if let panelViewController = presentedPanelViewController {
                addChild(panelViewController)

                view.setNeedsLayout()

                viewCode.contentView.installView(panelViewController.view, priority: .required)

                panelViewController.didMove(toParent: self)
            }

            if let oldPanelViewController = oldValue {
                oldPanelViewController.willMove(toParent: nil)

                oldPanelViewController.view.removeFromSuperview()

                oldPanelViewController.removeFromParent()
            }
        }
    }

    private lazy var viewCode = ElementInspectorViewCode(
        frame: CGRect(
            origin: .zero,
            size: ElementInspector.appearance.panelPreferredCompressedSize
        )
    ).then {
        $0.segmentedControl.addTarget(self, action: #selector(didChangeSelectedSegmentIndex), for: .valueChanged)

        $0.dismissBarButtonItem.target = self
        $0.dismissBarButtonItem.action = #selector(close)
    }

    // MARK: - Init

    static func create(viewModel: ElementInspectorViewModelProtocol) -> ElementInspectorViewController {
        let viewController = ElementInspectorViewController()
        viewController.viewModel = viewModel

        return viewController
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = viewCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = viewCode.segmentedControl

        if viewModel.showDismissBarButton {
            navigationItem.leftBarButtonItem = viewCode.dismissBarButtonItem
        }

        viewModel.availablePanels.reversed().forEach {
            viewCode.segmentedControl.insertSegment(
                with: $0.image.withRenderingMode(.alwaysTemplate),
                at: .zero,
                animated: false
            )
        }

        viewCode.segmentedControl.selectedSegmentIndex = viewModel.selectedPanelSegmentIndex

        if let selectedPanel = viewModel.selectedPanel {
            installPanel(selectedPanel)
        }
    }

    // MARK: - Content Size

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let newSize = calculatePreferredContentSize(with: container)

        return newSize
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        let newSize = calculatePreferredContentSize(with: container)

        preferredContentSize = newSize
    }

    private func calculatePreferredContentSize(with container: UIContentContainer) -> CGSize {
        guard let containerViewController = container as? UIViewController else {
            return .zero
        }

        return containerViewController.preferredContentSize
    }
}

// MARK: - Actions

extension ElementInspectorViewController {
    @discardableResult
    func selectPanelIfAvailable(_ panel: ElementInspectorPanel) -> Bool {
        guard let index = viewModel.availablePanels.firstIndex(of: panel) else {
            return false
        }

        viewCode.segmentedControl.selectedSegmentIndex = index

        installPanel(panel)

        return true
    }

    func removeCurrentPanel() {
        presentedPanelViewController = nil
    }
}

// MARK: - Private Actions

private extension ElementInspectorViewController {
    func installPanel(_ panel: ElementInspectorPanel) {
        guard let panelViewController = delegate?.elementInspectorFormPanelViewController(self, viewControllerFor: panel, with: viewModel.reference) else {
            presentedPanelViewController = nil
            return
        }

        presentedPanelViewController = panelViewController
    }

    @objc
    func didChangeSelectedSegmentIndex() {
        delegate?.cancelAllOperations()

        guard viewCode.segmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment else {
            removeCurrentPanel()
            return
        }

        let panel = viewModel.availablePanels[viewCode.segmentedControl.selectedSegmentIndex]

        installPanel(panel)
    }

    @objc
    func close() {
        delegate?.elementInspectorViewControllerDidFinish(self)
    }
}
