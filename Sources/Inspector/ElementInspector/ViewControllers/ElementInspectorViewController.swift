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

@_implementationOnly import UIKeyboardAnimatable
import UIKit

protocol ElementInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    func elementInspectorViewController(viewControllerWith panel: ElementInspectorPanel,
                                        and reference: ViewHierarchyReference) -> ElementInspectorPanelViewController

    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        didSelect reference: ViewHierarchyReference,
                                        with action: ViewHierarchyAction?,
                                        from fromReference: ViewHierarchyReference)

    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController)
}

final class ElementInspectorViewController: ElementInspectorPanelViewController, KeyboardAnimatable {
    weak var delegate: ElementInspectorViewControllerDelegate?

    let viewModel: ElementInspectorViewModelProtocol

    override var preferredContentSize: CGSize {
        didSet {
            Console.log(classForCoder, #function, preferredContentSize)
        }
    }

    override var isCompactVerticalPresentation: Bool {
        didSet {
            viewModel.isCompactVerticalPresentation = isCompactVerticalPresentation
        }
    }

    private lazy var viewCode = ElementInspectorViewCode(
        frame: CGRect(
            origin: .zero,
            size: ElementInspector.appearance.panelPreferredCompressedSize
        )
    ).then {
        $0.referenceSummaryView.viewModel = viewModel

        $0.segmentedControl.addTarget(self, action: #selector(didChangeSelectedSegmentIndex), for: .valueChanged)

        $0.dismissBarButtonItem.target = self
        $0.dismissBarButtonItem.action = #selector(close)
    }

    private(set) var currentPanelViewController: ElementInspectorPanelViewController? {
        didSet {
            if let oldPanelViewController = oldValue {
                oldPanelViewController.willMove(toParent: nil)

                oldPanelViewController.view.removeFromSuperview()

                oldPanelViewController.removeFromParent()
            }

            viewCode.containerStyle = .default

            guard let panelViewController = currentPanelViewController else {
                viewCode.emptyLabel.isHidden = false
                return
            }

            viewCode.emptyLabel.isHidden = true

            let animationDuration: TimeInterval = 0.18

            viewCode.activityIndicator.alpha = 0
            viewCode.activityIndicator.startAnimating()

            UIView.animate(withDuration: animationDuration, delay: animationDuration) { [weak self] in
                self?.viewCode.activityIndicator.alpha = 1
            }

            let operation = MainThreadOperation(name: "create \(panelViewController)") { [weak self] in
                guard let self = self else { return }

                self.addChild(panelViewController)

                guard let panelView = panelViewController.view else {
                    fatalError("Where's my view Mr. Panel?")
                }

                self.viewCode.containerStyle = panelViewController.hasScrollView ? .default : .scrollView

                self.viewCode.contentView.addArrangedSubview(panelView)

                panelView.alpha = 0
                panelView.backgroundColor = self.viewCode.backgroundColor
                panelView.isOpaque = true
                panelView.transform = .init(scaleX: 0.99, y: 0.98)
                    .translatedBy(x: .zero, y: -ElementInspector.appearance.verticalMargins)

                UIView.animate(
                    withDuration: animationDuration,
                    delay: .zero,
                    options: [.layoutSubviews, .curveEaseInOut],
                    animations: {
                        panelView.alpha = 1
                        panelView.transform = .identity
                    },
                    completion: { [weak self] _ in
                        guard let self = self else { return }

                        panelViewController.didMove(toParent: self)
                        NSObject.cancelPreviousPerformRequests(withTarget: self.viewCode.activityIndicator)
                        self.viewCode.activityIndicator.stopAnimating()
                        self.configureNavigationBarViews()
                    }
                )
            }

            OperationQueue.main.addOperation(operation)
        }
    }

    // MARK: - Init

    init(viewModel: ElementInspectorViewModelProtocol) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.title = viewModel.title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = viewCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            let interaction = UIContextMenuInteraction(delegate: self)
            viewCode.headerView.addInteraction(interaction)
        }

        animateWhenKeyboard(.willChangeFrame) { info in
            self.viewCode.keyboardHeight = info.keyboardFrame.height
            self.viewCode.layoutIfNeeded()
        }

        reloadData()
        configureNavigationBarViews()
    }

    private func configureNavigationBarViews() {
        navigationItem.rightBarButtonItem = viewCode.dismissBarButtonItem
        navigationItem.titleView = viewCode.segmentedControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()

        // here the view has updated its vertical compactness and we can load the panels
        guard viewCode.segmentedControl.numberOfSegments == .zero else { return }

        guard
            animated,
            let transitionCoordinator = transitionCoordinator
        else {
            updatePanelsSegmentedControl()
            installPanel(viewModel.currentPanel)
            return
        }

        viewCode.alpha = 0

        transitionCoordinator.animate(
            alongsideTransition: { context in
                self.viewCode.alpha = 1
                self.updatePanelsSegmentedControl()
                self.installPanel(self.viewModel.currentPanel)
            }
        )
    }

    func updatePanelsSegmentedControl() {
        viewCode.segmentedControl.removeAllSegments()

        viewModel.availablePanels.reversed().forEach {
            viewCode.segmentedControl.insertSegment(
                with: $0.image.withRenderingMode(.alwaysTemplate),
                at: .zero,
                animated: false
            )
        }

        viewCode.segmentedControl.selectedSegmentIndex = viewModel.currentPanelIndex
    }

    func reloadData() {
        viewCode.referenceSummaryView.reloadData()
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
        currentPanelViewController = nil
    }
}

// MARK: - Private Actions

private extension ElementInspectorViewController {
    func installPanel(_ panel: ElementInspectorPanel) {
        guard
            let panelViewController = delegate?.elementInspectorViewController(viewControllerWith: panel, and: viewModel.reference)
        else {
            currentPanelViewController = nil
            return
        }

        currentPanelViewController = panelViewController
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

// MARK: - Context Menu Interaction

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

                return self.viewModel.reference.menu(includeActions: false) { [weak self] reference, action in
                    guard let self = self else { return }

                    self.delegate?.elementInspectorViewController(
                        self,
                        didSelect: reference,
                        with: action,
                        from: self.viewModel.reference
                    )
                }
            }
        )
    }
}
