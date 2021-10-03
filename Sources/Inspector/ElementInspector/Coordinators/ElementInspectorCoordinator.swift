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

@_implementationOnly import Coordinator
import UIKit

// MARK: - Content View Controllers

final class ElementAttributesPanelViewController: ElementInspectorFormPanelViewController {}

final class ElementSizePanelViewController: ElementInspectorFormPanelViewController {}

final class ElementIdentityPanelViewController: ElementInspectorFormPanelViewController {}

// MARK: - ElementInspectorCoordinatorDelegate

protocol ElementInspectorCoordinatorDelegate: ViewHierarchyActionableProtocol & AnyObject {
    func elementInspectorCoordinator(
        _ coordinator: ElementInspectorCoordinator,
        didFinishInspecting element: ViewHierarchyElement,
        with reason: ElementInspectorDismissReason
    )
}

// MARK: - ElementInspectorCoordinator

final class ElementInspectorCoordinator: NavigationCoordinator {
    weak var delegate: ElementInspectorCoordinatorDelegate?

    let snapshot: ViewHierarchySnapshot

    let rootElement: ViewHierarchyElement

    let initialPanel: ElementInspectorPanel?

    let sourceView: UIView

    private lazy var slidingPanelAnimator = ElementInspectorSlidingPanelAnimator()

    private var rootWindow: UIWindow? { rootElement.rootView?.window }

    var isCapableOfSidePresentation: Bool {
        guard
            let rootWindow = rootWindow,
            ElementInspector.configuration.panelSidePresentationAvailable
        else {
            return false
        }
        
        let minimumSize = ElementInspector.configuration.panelSidePresentationMinimumContainerSize

        return rootWindow.frame.width >= minimumSize.width && rootWindow.frame.height >= minimumSize.height
    }

    func transitionDelegate(for viewController: UIViewController) -> UIViewControllerTransitioningDelegate? {
        switch viewController {
        case is ElementInspectorNavigationController where isCapableOfSidePresentation:
            return self
        default:
            return nil
        }
    }

    private(set) lazy var navigationController: ElementInspectorNavigationController = {
        let navigationController = makeNavigationController(from: sourceView)

        injectElementInspectorsForViewHierarchy(inside: navigationController)

        return navigationController
    }()

    private(set) lazy var operationQueue = OperationQueue.main

    init(
        element: ViewHierarchyElement,
        with panel: ElementInspectorPanel?,
        in snapshot: ViewHierarchySnapshot,
        from sourceView: UIView
    ) {
        self.rootElement = element
        self.initialPanel = panel
        self.snapshot = snapshot
        self.sourceView = sourceView
    }

    var permittedPopoverArrowDirections: UIPopoverArrowDirection {
        switch navigationController.popoverPresentationController?.arrowDirection {
        case .some(.up):
            return [.up, .left, .right]

        case .some(.down):
            return [.down, .left, .right]

        case .some(.left):
            return [.left]

        case .some(.right):
            return [.right]

        default:
            return .any
        }
    }

    func start() -> UINavigationController {
        navigationController
    }

    func finish(with reason: ElementInspectorDismissReason) {
        operationQueue.cancelAllOperations()
        operationQueue.isSuspended = true

        delegate?.elementInspectorCoordinator(self, didFinishInspecting: snapshot.rootElement, with: reason)
    }

    func setPopoverModalPresentationStyle(for viewController: UIViewController, from sourceView: UIView) {
        viewController.setPopoverModalPresentationStyle(
            delegate: self,
            transitionDelegate: transitionDelegate(for: viewController),
            from: sourceView
        )
    }

    static func makeElementInspectorViewController(
        with element: ViewHierarchyElement,
        elementLibraries: [InspectorElementLibraryProtocol],
        preferredPanel: ElementInspectorPanel?,
        initialPanel: ElementInspectorPanel?,
        delegate: ElementInspectorViewControllerDelegate,
        in snapshot: ViewHierarchySnapshot
    ) -> ElementInspectorViewController {
        let availablePanels = ElementInspectorPanel.allCases(for: element)

        let selectedPanel: ElementInspectorPanel?

        if let preferredPanel = preferredPanel, availablePanels.contains(preferredPanel) {
            selectedPanel = preferredPanel
        }
        else {
            selectedPanel = initialPanel
        }

        return ElementInspectorViewController(
            viewModel: ElementInspectorViewModel(
                snapshot: snapshot,
                element: element,
                selectedPanel: selectedPanel,
                inspectableElements: elementLibraries,
                availablePanels: availablePanels
            )
        ).then {
            $0.delegate = delegate
        }
    }

    func panelViewController(for panel: ElementInspectorPanel, with element: ViewHierarchyElement) -> ElementInspectorPanelViewController {
        switch panel {
        case .identity:
            let items: [ElementInspectorFormItem] = {
                guard let rootView = element.rootView else { return [] }

                return ElementInspectorIdentityLibrary.allCases
                    .map { $0.items(for: rootView) }
                    .flatMap { $0 }
            }()

            return ElementIdentityPanelViewController(
                dataSource: DefaultFormPanelDataSource(items: items) { indexPath in
                    let viewModel = items[indexPath.section].rows[indexPath.row]
                    return ElementInspectorIdentityLibrary.viewType(forViewModel: viewModel)
                }
            ).then {
                $0.formDelegate = self
            }

        case .attributes:
            return ElementAttributesPanelViewController(
                dataSource: DefaultFormPanelDataSource(
                    items: {
                        guard let rootView = element.rootView else { return [] }

                        return snapshot.elementLibraries.targeting(element: rootView).flatMap { library in
                            library.items(for: rootView)
                        }
                    }()
                )
            ).then {
                $0.formDelegate = self
            }

        case .children:
            return ElementChildrenPanelViewController(
                viewModel: ElementChildrenPanelViewModel(
                    element: element,
                    snapshot: snapshot
                )
            ).then {
                $0.delegate = self
            }

        case .size:
            let items: [ElementInspectorFormItem] = {
                guard let rootView = element.rootView else { return [] }

                return ElementInspectorSizeLibrary.allCases
                    .map { $0.items(for: rootView) }
                    .flatMap { $0 }
            }()

            return ElementSizePanelViewController(
                dataSource: DefaultFormPanelDataSource(items: items) { indexPath in
                    let viewModel = items[indexPath.section].rows[indexPath.row]
                    return ElementInspectorSizeLibrary.viewType(forViewModel: viewModel)
                }
            ).then {
                $0.formDelegate = self
            }
        }
    }

    var topElementInspectorViewController: ElementInspectorViewController? {
        navigationController.topViewController as? ElementInspectorViewController
    }

    var currentPanelViewController: ElementInspectorPanelViewController? {
        topElementInspectorViewController?.currentPanelViewController
    }

    func makeNavigationController(from sourceView: UIView) -> ElementInspectorNavigationController {
        let navigationController = ElementInspectorNavigationController()
        navigationController.dismissDelegate = self

        setPopoverModalPresentationStyle(for: navigationController, from: sourceView)

        return navigationController
    }
}

// MARK: - ViewHierarchyActionableProtocol

extension ElementInspectorCoordinator: ViewHierarchyActionableProtocol {
    func canPerform(action: ViewHierarchyAction) -> Bool {
        switch action {
        case .inspect:
            return true
        case .copy, .layer:
            return false
        }
    }

    func perform(action: ViewHierarchyAction, with element: ViewHierarchyElement, from sourceView: UIView) {
        guard canPerform(action: action) else {
            delegate?.perform(action: action, with: element, from: sourceView)
            return
        }

        guard case let .inspect(preferredPanel) = action else {
            assertionFailure("should not happen")
            return
        }

        if element == topElementInspectorViewController?.viewModel.element {
            topElementInspectorViewController?.selectPanelIfAvailable(preferredPanel)
            return
        }

        operationQueue.cancelAllOperations()

        let pushOperation = MainThreadOperation(name: "Push \(element.displayName)") { [weak self] in
            guard let self = self else { return }

            let elementInspectorViewController = Self.makeElementInspectorViewController(
                with: element,
                elementLibraries: self.snapshot.elementLibraries,
                preferredPanel: preferredPanel,
                initialPanel: self.initialPanel,
                delegate: self,
                in: self.snapshot
            )

            self.navigationController.pushViewController(elementInspectorViewController, animated: true)
        }

        addOperationToQueue(pushOperation)
    }
}

// MARK: - DismissablePresentationProtocol

extension ElementInspectorCoordinator: DismissablePresentationProtocol {
    func dismissPresentation(animated: Bool) {
        if let presentingViewController = navigationController.presentingViewController {
            presentingViewController.dismiss(animated: animated, completion: nil)
        }
    }
}

// MARK: - Private Helpers

private extension ElementInspectorCoordinator {
    func injectElementInspectorsForViewHierarchy(inside navigationController: ElementInspectorNavigationController) {
        let populatedElements = snapshot.inspectableElements.filter { $0.rootView === rootElement.rootView }

        guard let populatedElement = populatedElements.first else {
            let rootViewController = Self.makeElementInspectorViewController(
                with: snapshot.rootElement,
                elementLibraries: snapshot.elementLibraries,
                preferredPanel: initialPanel,
                initialPanel: initialPanel,
                delegate: self,
                in: snapshot
            )

            navigationController.viewControllers = [rootViewController]

            return
        }

        navigationController.viewControllers = {
            var array = [UIViewController]()

            var element: ViewHierarchyElement? = populatedElement

            while element != nil {
                guard let currentElement = element else {
                    break
                }

                let viewController = Self.makeElementInspectorViewController(
                    with: currentElement,
                    elementLibraries: snapshot.elementLibraries,
                    preferredPanel: initialPanel,
                    initialPanel: initialPanel,
                    delegate: self,
                    in: snapshot
                )

                array.append(viewController)

                element = currentElement.parent
            }

            return array.reversed()
        }()
    }
}

extension ElementInspectorCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard transitionDelegate(for: presented) != nil else { return nil }

        switch presented {
        case is ElementInspectorNavigationController:
            slidingPanelAnimator.isPresenting = true
            return slidingPanelAnimator
        default:
            return nil
        }
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard transitionDelegate(for: dismissed) != nil else { return nil }

        switch dismissed {
        case is ElementInspectorNavigationController:
            slidingPanelAnimator.isPresenting = false
            return slidingPanelAnimator
        default:
            return nil
        }
    }
}
