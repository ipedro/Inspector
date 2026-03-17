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

internal import UIKeyboardAnimatable
import UIKit

enum ElementInspectorDismissReason: Swift.CaseIterable {
    case dismiss

    var title: String {
        switch self {
        case .dismiss:
            "Dismiss"
        }
    }

    var icon: UIImage? {
        switch self {
        case .dismiss:
            .closeSymbol
        }
    }
}

protocol ElementInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    func elementInspectorViewController(viewControllerWith panel: ElementInspectorPanel,
                                        and element: ViewHierarchyElementReference) -> ElementInspectorPanelViewController

    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        didSelect element: ViewHierarchyElementReference,
                                        with action: ViewHierarchyElementAction,
                                        from fromElement: ViewHierarchyElementReference)

    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController,
                                                 with reason: ElementInspectorDismissReason)
}

final class ElementInspectorViewController: ElementInspectorPanelViewController, KeyboardAnimatable, DataReloadingProtocol {
    weak var delegate: ElementInspectorViewControllerDelegate?

    let viewModel: ElementInspectorViewModelProtocol

    override var preferredContentSize: CGSize {
        didSet {
            Logger.log(classForCoder, #function, preferredContentSize)
        }
    }

    override var isFullHeightPresentation: Bool {
        didSet {
            viewModel.isFullHeightPresentation = isFullHeightPresentation
        }
    }

    private lazy var segmentedControl = UISegmentedControl.segmentedControlStyle().then {
        $0.addTarget(self, action: #selector(didChangeSelectedSegmentIndex), for: .valueChanged)
        $0.addInteraction(UIContextMenuInteraction(delegate: self))
    }

    private lazy var toggleCollapseButton = ToogleCollapseButton().then {
        $0.addTarget(self, action: #selector(didTapToggleCollapseButton), for: .touchUpInside)
        $0.addInteraction(UIContextMenuInteraction(delegate: self))
    }

    private let dismissItem: UIBarButtonItem.SystemItem = .close

    private(set) lazy var dismissBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: dismissItem,
        target: self,
        action: #selector(dismiss(_:))
    )

    private lazy var viewCode = ElementInspectorViewCode(
        frame: CGRect(
            origin: .zero,
            size: Inspector.sharedInstance.configuration.elementInspectorConfiguration.panelPreferredCompressedSize
        )
    ).then {
        $0.elementDescriptionView.summaryInfo = viewModel.element.summaryInfo
    }

    @objc
    private func didTapToggleCollapseButton() {
        toggleCollapseButton.collapseState = .none

        guard let formPanel = currentPanelViewController as? ElementInspectorFormPanelViewController else { return }

        DispatchQueue.main.async {
            formPanel.togglePanels(to: formPanel.listState.next() ?? .allCollapsed, animated: true)
        }
    }

    var currentFormPanelViewController: ElementInspectorFormPanelViewController? {
        currentPanelViewController as? ElementInspectorFormPanelViewController
    }

    override func calculatePreferredContentSize() -> CGSize {
        let superSize = super.calculatePreferredContentSize()
        let contentSize = viewCode.contentSize

        return CGSize(
            width: max(superSize.width, contentSize.width),
            height: max(superSize.height, contentSize.height)
        )
    }

    private(set) var currentPanelViewController: ElementInspectorPanelViewController? {
        didSet {
            oldValue?.willMove(toParent: nil)

            if let formPanel = currentFormPanelViewController {
                formPanel.itemStateDelegate = self
            }

            viewCode.setContentAnimated(.loadingIndicator)

            segmentedControl.isUserInteractionEnabled = false

            let operation = MainThreadAsyncOperation(name: "install panel") { [weak self] in
                guard let self else {
                    oldValue?.removeFromParent()
                    return
                }

                guard let panelViewController = currentPanelViewController else {
                    viewCode.content = .empty(withMessage: "Lost connection to element")
                    segmentedControl.isUserInteractionEnabled = true
                    return
                }

                let content: ElementInspectorViewCode.Content = {
                    if let panelScrollView = panelViewController.panelScrollView {
                        return .scrollView(panelScrollView)
                    }
                    return .panelView(panelViewController.view)
                }()

                addChild(panelViewController)

                viewCode.setContentAnimated(content) { [weak self] in
                    self?.configureNavigationItem()

                    if let formPanel = self?.currentFormPanelViewController {
                        self?.toggleCollapseButton.alpha = 1
                        self?.toggleCollapseButton.isHidden = false
                        self?.toggleCollapseButton.collapseState = formPanel.listState
                    }
                    else {
                        self?.toggleCollapseButton.alpha = 0
                        self?.toggleCollapseButton.isHidden = true
                    }

                    self?.updatePreferredContentSize()

                } completion: { [weak self] _ in
                    oldValue?.didMove(toParent: nil)
                    oldValue?.removeFromParent()

                    guard let self else { return }

                    segmentedControl.isUserInteractionEnabled = true
                    panelViewController.didMove(toParent: self)

                    animate(withDuration: .veryLong) { [weak self] in
                        self?.updatePreferredContentSize()
                    }
                }
            }

            OperationQueue.main.addOperation(operation)
        }
    }

    // MARK: - Init

    init(viewModel: ElementInspectorViewModelProtocol) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
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

        reloadData()
        configureNavigationItem()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopAnimatingWhenKeyboard(.willChangeFrame)
        currentPanelViewController?.viewDidDisappear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _ in
            //
        } completion: { [weak self] _ in
            guard let self else { return }
            reloadData()
            (currentPanelViewController as? DataReloadingProtocol)?.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPanelViewController?.viewWillAppear(animated)

        if segmentedControl.numberOfSegments == .zero {
            updatePanelsSegmentedControl()
            installPanel(viewModel.currentPanel)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentPanelViewController?.viewDidAppear(animated)

        animateWhenKeyboard(.willChangeFrame) { [weak self] info in
            guard let self else { return }
            viewCode.keyboardHeight = info.keyboardFrame.height
            viewCode.layoutIfNeeded()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentPanelViewController?.viewWillDisappear(animated)
    }

    private func configureNavigationItem() {
        navigationItem.rightBarButtonItems = [dismissBarButtonItem, .init(customView: toggleCollapseButton)]
        navigationItem.titleView = segmentedControl
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func updatePanelsSegmentedControl() {
        segmentedControl.removeAllSegments()

        for availablePanel in viewModel.availablePanels.reversed() {
            segmentedControl.insertSegment(
                with: availablePanel.image?.withRenderingMode(.alwaysTemplate),
                at: .zero,
                animated: false
            )
        }

        segmentedControl.selectedSegmentIndex = viewModel.currentPanelIndex
    }

    func reloadData() {
        title = viewModel.element.summaryInfo.title
        viewCode.elementDescriptionView.summaryInfo = viewModel.element.summaryInfo
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
    func selectPanelIfAvailable(_ panel: ElementInspectorPanel?) -> Bool {
        guard
            let panel,
            let index = viewModel.availablePanels.firstIndex(of: panel)
        else {
            return false
        }

        segmentedControl.selectedSegmentIndex = index

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
        guard let newPanelViewController = delegate?.elementInspectorViewController(viewControllerWith: panel, and: viewModel.element) else {
            currentPanelViewController = nil
            return
        }

        currentPanelViewController = newPanelViewController
    }

    @objc
    func didChangeSelectedSegmentIndex() {
        delegate?.cancelAllOperations()

        guard segmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment else {
            removeCurrentPanel()
            return
        }

        let panel = viewModel.availablePanels[segmentedControl.selectedSegmentIndex]

        installPanel(panel)
    }

    @objc
    func dismiss(_ sender: Any) {
        delegate?.elementInspectorViewControllerDidFinish(self, with: .dismiss)
    }
}

extension ElementInspectorViewController: ElementInspectorFormPanelItemStateDelegate {
    func elementInspectorFormPanelItemDidChangeState(_ formPanelViewController: ElementInspectorFormPanelViewController) {
        toggleCollapseButton.collapseState = formPanelViewController.listState
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension ElementInspectorViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        switch interaction.view {
        case segmentedControl:
            .init { _ in .defaultElementInspectorPanelMenu() }

        case toggleCollapseButton:
            .init { [weak self] _ in
                guard let self else { return nil }

                return UIMenu(
                    title: "",
                    image: nil,
                    identifier: nil,
                    options: .displayInline,
                    children: nextActions(for: toggleCollapseButton.collapseState)
                )
            }

        default:
            nil
        }
    }

    private func nextActions(for currentState: ElementInspectorPanelListState?) -> [UIMenuElement] {
        guard let firstState = currentState?.next() else {
            let state = ElementInspectorPanelListState.allCollapsed

            return [
                UIAction(
                    title: state.title,
                    image: state.image,
                    identifier: nil,
                    discoverabilityTitle: state.title,
                    handler: { [weak self] _ in
                        self?.currentFormPanelViewController?.togglePanels(to: state, animated: true)
                    }
                )
            ]
        }

        var actions = [UIMenuElement]()

        var state: ElementInspectorPanelListState? = firstState

        while state != nil {
            guard let nextState = state else { return actions }

            if nextState != currentState {
                actions.append(
                    UIAction(
                        title: nextState.title,
                        image: nextState.image,
                        identifier: nil,
                        discoverabilityTitle: nextState.title,
                        handler: { [weak self] _ in
                            self?.currentFormPanelViewController?.togglePanels(to: nextState, animated: true)
                        }
                    )
                )
            }

            state = nextState.next()
        }

        return actions
    }
}

private extension UIMenu {
    static func defaultElementInspectorPanelMenu() -> UIMenu {
        UIMenu(
            title: "Select Default Panel",
            image: nil,
            identifier: nil,
            children: ElementInspectorPanel.allCases.map { panel in
                UIAction(
                    title: panel.title,
                    image: panel.image,
                    identifier: nil,
                    discoverabilityTitle: panel.title,
                    state: panel.isDefault ? .on : .off
                ) { _ in
                    Inspector.sharedInstance.configuration.elementInspectorConfiguration.defaultPanel = panel
                }
            }
        )
    }
}
