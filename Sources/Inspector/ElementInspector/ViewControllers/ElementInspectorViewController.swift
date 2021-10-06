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

enum ElementInspectorDismissReason: Swift.CaseIterable {
    case dismiss
    case stopInspecting

    var title: String {
        switch self {
        case .dismiss:
            return "Dismiss"
        case .stopInspecting:
            return "Stop Inspecting"
        }
    }

    @available(iOS 13.0, *)
    var icon: UIImage? {
        switch self {
        case .dismiss:
            return .closeSymbol
        case .stopInspecting:
            return .stopSymbol
        }
    }
}

protocol ElementInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    func elementInspectorViewController(viewControllerWith panel: ElementInspectorPanel,
                                        and element: ViewHierarchyElement) -> ElementInspectorPanelViewController

    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        didSelect element: ViewHierarchyElement,
                                        with action: ViewHierarchyAction,
                                        from fromElement: ViewHierarchyElement)

    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController,
                                                 with reason: ElementInspectorDismissReason)
}

final class ElementInspectorViewController: ElementInspectorPanelViewController, KeyboardAnimatable, DataReloadingProtocol {
    weak var delegate: ElementInspectorViewControllerDelegate?

    let viewModel: ElementInspectorViewModelProtocol

    override var preferredContentSize: CGSize {
        didSet {
            Console.log(classForCoder, #function, preferredContentSize)
        }
    }

    override var isFullHeightPresentation: Bool {
        didSet {
            viewModel.isFullHeightPresentation = isFullHeightPresentation
        }
    }

    private lazy var segmentedControl = UISegmentedControl.segmentedControlStyle().then {
        $0.addTarget(self, action: #selector(didChangeSelectedSegmentIndex), for: .valueChanged)

        if #available(iOS 13.0, *) {
            $0.addInteraction(UIContextMenuInteraction(delegate: self))
        }
    }

    private lazy var toggleCollapseButton = ToogleCollapseButton().then {
        $0.addTarget(self, action: #selector(didTapToggleCollapseButton), for: .touchUpInside)

        if #available(iOS 13.0, *) {
            $0.addInteraction(UIContextMenuInteraction(delegate: self))
        }
    }

    private let dismissItem: UIBarButtonItem.SystemItem = {
        if #available(iOS 13.0, *) {
            return .close
        }
        else {
            return .done
        }
    }()

    private(set) lazy var dismissBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: dismissItem,
        target: self,
        action: #selector(dismiss(_:))
    ).then {
        if #available(iOS 14.0, *) {
            $0.menu = UIMenu(
                title: String(),
                image: nil,
                identifier: nil,
                children: ElementInspectorDismissReason.allCases.map { action in
                    UIAction(
                        title: action.title,
                        image: action.icon,
                        identifier: nil,
                        discoverabilityTitle: action.title
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        self.delegate?.elementInspectorViewControllerDidFinish(self, with: action)
                    }
                }
            )
        }
    }

    private lazy var viewCode = ElementInspectorViewCode(
        frame: CGRect(
            origin: .zero,
            size: ElementInspector.configuration.panelPreferredCompressedSize
        )
    ).then {
        $0.elementDescriptionView.viewModel = viewModel
    }

    @objc
    private func didTapToggleCollapseButton() {
        toggleCollapseButton.collapseState = .none

        guard let formPanel = currentPanelViewController as? ElementInspectorFormPanelViewController else { return }

        DispatchQueue.main.async {
            formPanel.togglePanels(to: formPanel.collapseState.next() ?? .allCollapsed, animated: true)
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
                guard let self = self else {
                    oldValue?.removeFromParent()
                    return
                }

                guard let panelViewController = self.currentPanelViewController else {
                    self.viewCode.content = .empty(withMessage: "Lost connection to element")
                    self.segmentedControl.isUserInteractionEnabled = true
                    return
                }

                let content: ElementInspectorViewCode.Content = {
                    if let panelScrollView = panelViewController.panelScrollView {
                        return .scrollView(panelScrollView)
                    }
                    return .panelView(panelViewController.view)
                }()

                self.addChild(panelViewController)

                self.viewCode.setContentAnimated(content) { [weak self] in
                    self?.configureNavigationItem()

                    if let formPanel = self?.currentFormPanelViewController {
                        self?.toggleCollapseButton.alpha = 1
                        self?.toggleCollapseButton.isHidden = false
                        self?.toggleCollapseButton.collapseState = formPanel.collapseState
                    }
                    else {
                        self?.toggleCollapseButton.alpha = 0
                        self?.toggleCollapseButton.isHidden = true
                    }

                    self?.updatePreferredContentSize()

                } completion: { [weak self] _ in
                    oldValue?.didMove(toParent: nil)
                    oldValue?.removeFromParent()

                    guard let self = self else { return }

                    self.segmentedControl.isUserInteractionEnabled = true
                    panelViewController.didMove(toParent: self)

                    self.animate(withDuration: .veryLong) { [weak self] in
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

        animateWhenKeyboard(.willChangeFrame) { info in
            self.viewCode.keyboardHeight = info.keyboardFrame.height
            self.viewCode.layoutIfNeeded()
        }

        reloadData()
        configureNavigationItem()
    }

    private func configureNavigationItem() {
        navigationItem.rightBarButtonItems = [dismissBarButtonItem, .init(customView: toggleCollapseButton)]
        navigationItem.titleView = segmentedControl
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _ in
            //
        } completion: { _ in
            self.reloadData()
            (self.currentPanelViewController as? DataReloadingProtocol)?.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPanelViewController?.viewWillAppear(animated)

        if segmentedControl.numberOfSegments == .zero {
            updatePanelsSegmentedControl()

            if let panel = viewModel.currentPanel {
                installPanel(panel)
            }
        }

        guard
            animated,
            let transitionCoordinator = transitionCoordinator
        else {
            return
        }

        // The mask will shrink to half the width during the animation:
        let maskViewNewFrame = CGRect(origin: .zero, size: CGSize(width: 0.3 * view.frame.width, height: view.frame.height))

        let maskView = UIView(frame: maskViewNewFrame) // CGRect(origin: .zero, size: view.frame.size))
        maskView.backgroundColor = .white

        viewCode.alpha = 0

        // FIXME: convert to proper transition coordinator
        transitionCoordinator.animate { transitionContext in

            self.viewCode.alpha = 1

            guard
                let fromViewController = transitionContext.viewController(forKey: .from) as? ElementInspectorViewController,
                let toViewController = transitionContext.viewController(forKey: .to) as? ElementInspectorViewController,
                let fromView = fromViewController.view,
                let toView = toViewController.view
            else {
                return
            }

            transitionContext.containerView.subviews.first(where: { $0.className.contains("DimmingView") })?.isHidden = true

            if toView === self.view {
                // Apply a white UIView as mask to the SOURCE view:
                toView.mask = maskView
                toView.mask?.frame = toView.bounds
            }

            fromView.alpha = 0

        } completion: { transitionContext in
            self.viewCode.alpha = 1
            self.viewCode.mask = nil

            guard
                let fromViewController = transitionContext.viewController(forKey: .from) as? ElementInspectorViewController,
                let fromView = fromViewController.view
            else {
                return
            }

            // Remove mask, otherwise funny things will happen if toView is a
            // scroll or table view and the user "rubberbands":
            fromView.mask = nil
            fromView.alpha = 1
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentPanelViewController?.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        defer {
            super.viewWillDisappear(animated)
            currentPanelViewController?.viewWillDisappear(animated)
        }

        transitionCoordinator?.animate { transitionContext in
            guard
                let toViewController = transitionContext.viewController(forKey: .to) as? ElementInspectorViewController,
                let toView = toViewController.view
            else {
                return
            }

            if toView === self.view {
                // Apply a white UIView as mask to the DESTINATION view, at the begining
                // revealing only the left-most half:
                let halfWidthSize = CGSize(width: 0.3 * toView.frame.width, height: toView.frame.height)
                let maskView = UIView(frame: CGRect(origin: .init(x: -0.5 * toView.frame.width, y: .zero), size: halfWidthSize))
                maskView.backgroundColor = .white
                toView.mask = maskView
                // And calculate a new frame to make it grow back to full width during
                // the animation:
                let maskViewNewFrame = toView.bounds

                maskView.frame = maskViewNewFrame // (Mask back to full width: no clipping)
            }

            self.viewCode.alpha = 0

        } completion: { transitionContext in
            self.viewCode.mask = nil
            self.viewCode.alpha = 1

            guard
                let toViewController = transitionContext.viewController(forKey: .to) as? ElementInspectorViewController,
                let toView = toViewController.view
            else {
                return
            }

            // Remove mask, otherwise funny things will happen if toView is a
            // scroll or table view and the user "rubberbands":
            toView.mask = nil
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        currentPanelViewController?.viewDidDisappear(animated)
    }

    func updatePanelsSegmentedControl() {
        segmentedControl.removeAllSegments()

        viewModel.availablePanels.reversed().forEach {
            segmentedControl.insertSegment(
                with: $0.image?.withRenderingMode(.alwaysTemplate),
                at: .zero,
                animated: false
            )
        }

        segmentedControl.selectedSegmentIndex = viewModel.currentPanelIndex
    }

    func reloadData() {
        viewCode.elementDescriptionView.reloadData()
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
            let panel = panel,
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
        toggleCollapseButton.collapseState = formPanelViewController.collapseState
    }
}

// MARK: - UIContextMenuInteractionDelegate

@available(iOS 13.0, *)
extension ElementInspectorViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        switch interaction.view {
        case segmentedControl:
            return .init { _ in .defaultElementInspectorPanelMenu() }

        case toggleCollapseButton:
            return .init { [weak self] _ in
                guard let self = self else { return nil }

                return UIMenu(
                    title: "",
                    image: nil,
                    identifier: nil,
                    options: .displayInline,
                    children: self.nextActions(for: self.toggleCollapseButton.collapseState)
                )
            }

        default:
            return nil
        }
    }

    private func nextActions(for currentState: ElementInspectorPanelListState?) -> [UIMenuElement] {
        guard let firstState = currentState?.next() else {
            let state =  ElementInspectorPanelListState.allCollapsed

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

@available(iOS 13.0, *)
private extension UIMenu {
    static func defaultElementInspectorPanelMenu() -> UIMenu {
        UIMenu(
            title: "Default Panel",
            image: nil,
            identifier: nil,
            children: ElementInspectorPanel.allCases.map { panel in
                UIAction(
                    title: panel.title,
                    image: panel.image,
                    identifier: nil,
                    discoverabilityTitle: panel.title,
                    state: ElementInspector.configuration.defaultPanel == panel ? .on : .off
                ) { _ in
                    ElementInspector.configuration.defaultPanel = panel
                }
            }
        )
    }
}
