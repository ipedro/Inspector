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

enum ElementInspectorDismissAction: Swift.CaseIterable {
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
                                        and reference: ViewHierarchyReference) -> ElementInspectorPanelViewController

    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        didSelect reference: ViewHierarchyReference,
                                        with action: ViewHierarchyAction?,
                                        from fromReference: ViewHierarchyReference)

    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController,
                                                 with dismissAction: ElementInspectorDismissAction)
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
        $0.dismissBarButtonItem.action = #selector(dismiss(_:))

        if #available(iOS 14.0, *) {
            $0.dismissBarButtonItem.menu = UIMenu(
                title: String(),
                image: nil,
                identifier: nil,
                children: ElementInspectorDismissAction.allCases.map { action in
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

    private(set) var currentPanelViewController: ElementInspectorPanelViewController? {
        didSet {
            if let oldPanelViewController = oldValue {
                oldPanelViewController.willMove(toParent: nil)

                oldPanelViewController.view.removeFromSuperview()

                oldPanelViewController.removeFromParent()
            }

            viewCode.containerStyle = .static

            guard let panelViewController = currentPanelViewController else {
                viewCode.emptyLabel.isHidden = false
                return
            }

            viewCode.emptyLabel.isHidden = true

            let animationDuration: TimeInterval = 0.18

            animate(delay: animationDuration) { [weak self] in
                self?.viewCode.activityIndicator.startAnimating()
                self?.viewCode.activityIndicator.alpha = 1
            }

            let operation = MainThreadOperation(name: "create \(panelViewController)") { [weak self] in
                guard let self = self else { return }

                self.addChild(panelViewController)

                guard let panelView = panelViewController.view else {
                    fatalError("Where's my view Mr. Panel?")
                }

                self.viewCode.containerStyle = panelViewController.hasScrollView ? .static : .scrollView

                self.viewCode.contentView.addArrangedSubview(panelView)

                panelView.alpha = 0
                panelView.transform = .init(scaleX: 0.99, y: 0.98)
                    .translatedBy(x: .zero, y: -ElementInspector.appearance.verticalMargins)

                self.animate(
                    withDuration: animationDuration,
                    options: [.layoutSubviews, .beginFromCurrentState],
                    animations: {
                        panelView.alpha = 1
                        panelView.transform = .identity
                        self.viewCode.activityIndicator.alpha = 0
                    },
                    completion: { [weak self] _ in
                        guard let self = self else { return }

                        panelViewController.didMove(toParent: self)
                        NSObject.cancelPreviousPerformRequests(withTarget: self.viewCode.activityIndicator)
                        self.viewCode.activityIndicator.stopAnimating()
                        self.viewCode.activityIndicator.alpha = 0
                        self.configureNavigationItem()
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
        configureNavigationItem()
    }

    private func configureNavigationItem() {
        navigationItem.backBarButtonItem?.tintColor = colorStyle.tintColor
        navigationItem.leftBarButtonItem?.tintColor = colorStyle.tintColor
        navigationItem.rightBarButtonItem = viewCode.dismissBarButtonItem
        navigationItem.titleView = viewCode.segmentedControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if viewCode.segmentedControl.numberOfSegments == .zero {
            updatePanelsSegmentedControl()
            installPanel(viewModel.currentPanel)
        }

        guard
            animated,
            let transitionCoordinator = transitionCoordinator
        else {
            return
        }

        // The mask will shrink to half the width during the animation:
        let maskViewNewFrame = CGRect(origin: .zero, size: CGSize(width: 0.3 * view.frame.width, height: view.frame.height))

        let maskView = UIView(frame: maskViewNewFrame)// CGRect(origin: .zero, size: view.frame.size))
        maskView.backgroundColor = .white

        viewCode.alpha = 0

        // compensate for transition drop shadow
        let backgroundView = UIView()
        backgroundView.backgroundColor = colorStyle.panelTransitionBackgorundColor

        transitionCoordinator.animate { transitionContext in

            transitionContext.containerView.installView(backgroundView, position: .behind)

            self.viewCode.alpha = 1

            guard
                let fromViewController = transitionContext.viewController(forKey: .from) as? ElementInspectorViewController,
                let toViewController = transitionContext.viewController(forKey: .to) as? ElementInspectorViewController,
                let fromView = fromViewController.view,
                let toView = toViewController.view
            else {
                return
            }

            if toView === self.view {
                // Apply a white UIView as mask to the SOURCE view:
                toView.mask = maskView
                toView.mask?.frame = toView.bounds
            }
            
            fromView.alpha = 0

        } completion: { transitionContext in
            self.viewCode.alpha = 1
            self.viewCode.mask = nil

            backgroundView.removeFromSuperview()

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

    override func viewWillDisappear(_ animated: Bool) {
        defer {
            super.viewWillDisappear(animated)
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
            let newPanelViewController = delegate?.elementInspectorViewController(viewControllerWith: panel, and: viewModel.reference)
        else {
            currentPanelViewController = nil
            return
        }

        if
            let previousPanelViewController = currentPanelViewController,
            type(of: previousPanelViewController) == type(of: newPanelViewController)
        {
            return
        }

        currentPanelViewController = newPanelViewController
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
    func dismiss(_ sender: Any) {
        delegate?.elementInspectorViewControllerDidFinish(self, with: .dismiss)
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
