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

// MARK: - ElementInspectorCoordinatorDelegate

protocol ElementInspectorCoordinatorDelegate: ViewHierarchyActionableProtocol & AnyObject {
    func elementInspectorCoordinator(
        _ coordinator: ElementInspectorCoordinator,
        didFinishInspecting element: ViewHierarchyElementReference,
        with reason: ElementInspectorDismissReason
    )
}

// MARK: - ElementInspectorCoordinator

struct ElementInspectorDependencies {
    var catalog: ViewHierarchyElementCatalog
    var initialPanel: ElementInspectorPanel?
    var rootElement: ViewHierarchyElementReference
    var snapshot: ViewHierarchySnapshot
    var sourceView: UIView
}

final class ElementInspectorCoordinator: Coordinator<ElementInspectorDependencies, UIWindow, UINavigationController> {
    weak var delegate: ElementInspectorCoordinatorDelegate?

    private(set) lazy var slidingPanelAnimator = ElementInspectorSlidingPanelAnimator()

    private(set) lazy var transitionPresenter = UIViewControllerTransitionPresenter().then {
        $0.delegate = self
    }

    private var formPanelController: ElementInspectorFormPanelViewController? { currentPanelViewController as? ElementInspectorFormPanelViewController }

    private(set) lazy var adaptiveModalPresenter = AdaptiveModalPresenter(
        presentationStyle: { presentationController, _ in
            switch presentationController.presentedViewController {
            case let navigationController as ElementInspectorNavigationController where navigationController.shouldAdaptModalPresentation == false:
                return .none
            default:
                #if swift(>=5.5)
                if #available(iOS 15.0, *) {
                    if presentationController is UIPopoverPresentationController {
                        return presentationController.presentationStyle
                    }
                }
                #endif
                return .formSheet
            }
        },
        onChangeSelectedDetent: { [weak self] detent in
            guard let self = self else { return }
            self.formPanelController?.isFullHeightPresentation = detent == .large
        },
        onDismiss: { [weak self] presentationController in
            guard let self = self else { return }
            if self.navigationController === presentationController.presentedViewController {
                self.finish(with: .dismiss)
            }
        }
    )

    @available(iOS 14.0, *)
    private(set) lazy var colorPicker = ColorPickerPresenter(
        onColorSelected: { [weak self] selectedColor in
            guard let self = self else { return }
            self.formPanelController?.selectColor(selectedColor)
        },
        onDimiss: { [weak self] in
            guard let self = self else { return }
            self.formPanelController?.finishColorSelection()
        }
    )

    private(set) lazy var documentPicker = DocumentPickerPresenter { [weak self] urls in
        guard let self = self else { return }

        for url in urls {
            guard let data = try? Data(contentsOf: url) else { continue }
            let image = UIImage(data: data)
            self.formPanelController?.selectImage(image)
            break
        }
    }

    var isCapableOfSidePresentation: Bool {
        guard Inspector.sharedInstance.configuration.elementInspectorConfiguration.panelSidePresentationAvailable else { return false }
        let minimumSize = Inspector.sharedInstance.configuration.elementInspectorConfiguration.panelSidePresentationMinimumContainerSize
        return presenter.frame.width >= minimumSize.width && presenter.frame.height >= minimumSize.height
    }

    func transitionDelegate(for viewController: UIViewController) -> UIViewControllerTransitioningDelegate? {
        switch viewController {
        case is ElementInspectorNavigationController where isCapableOfSidePresentation:
            return transitionPresenter
        default:
            return nil
        }
    }

    private(set) lazy var navigationController: ElementInspectorNavigationController = {
        let navigationController = makeNavigationController(from: dependencies.sourceView)

        injectElementInspectorsForViewHierarchy(inside: navigationController, dependencies: dependencies)

        return navigationController
    }()

    private(set) lazy var operationQueue = OperationQueue.main

    override func loadContent() -> UINavigationController {
        navigationController
    }

    func finish(with reason: ElementInspectorDismissReason) {
        operationQueue.cancelAllOperations()
        operationQueue.isSuspended = true

        delegate?.elementInspectorCoordinator(self, didFinishInspecting: dependencies.rootElement, with: reason)
    }

    func setPopoverModalPresentationStyle(for viewController: UIViewController, from sourceView: UIView) {
        if #available(iOS 15.0, *) {
            viewController.setPopoverModalPresentationStyle(
                delegate: adaptiveModalPresenter,
                transitionDelegate: transitionDelegate(for: viewController),
                from: sourceView
            )
        }
        else {
            viewController.setPopoverModalPresentationStyle(
                delegate: adaptiveModalPresenter,
                transitionDelegate: transitionDelegate(for: viewController),
                from: sourceView
            )
        }
    }

    static func makeElementInspectorViewController(
        element: ViewHierarchyElementReference,
        preferredPanel: ElementInspectorPanel?,
        initialPanel: ElementInspectorPanel?,
        delegate: ElementInspectorViewControllerDelegate,
        catalog: ViewHierarchyElementCatalog
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
                catalog: catalog,
                element: element,
                preferredPanel: selectedPanel,
                availablePanels: availablePanels
            )
        ).then {
            $0.delegate = delegate
        }
    }

    func panelViewController(for panel: ElementInspectorPanel, with element: ViewHierarchyElementReference) -> ElementInspectorPanelViewController {
        switch panel {
        case .identity, .attributes, .size:
            let dataSource = DefaultFormPanelDataSource(
                sections: {
                    guard let libraries = dependencies.catalog.libraries[panel] else { return [] }
                    return libraries.formItems(for: element.underlyingObject)
                }()
            )

            return ElementInspectorFormPanelViewController().then {
                $0.dataSource = dataSource
                $0.formDelegate = self
                $0.initialCompactListState = .allCollapsed
                $0.initialListState = .firstExpanded
            }

        case .children:
            return ElementChildrenPanelViewController(
                viewModel: ElementChildrenPanelViewModel(
                    element: element,
                    snapshot: dependencies.snapshot
                )
            ).then {
                $0.delegate = self
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
    func canPerform(action: ViewHierarchyElementAction) -> Bool {
        switch action {
        case .inspect:
            return true
        case .copy, .layer:
            return false
        }
    }

    func perform(action: ViewHierarchyElementAction, with element: ViewHierarchyElementReference, from sourceView: UIView) {
        guard canPerform(action: action) else {
            delegate?.perform(action: action, with: element, from: sourceView)
            return
        }

        guard case let .inspect(preferredPanel) = action else {
            assertionFailure("should not happen")
            return
        }

        if element.objectIdentifier == topElementInspectorViewController?.viewModel.element.objectIdentifier {
            topElementInspectorViewController?.selectPanelIfAvailable(preferredPanel)
            return
        }

        operationQueue.cancelAllOperations()

        let pushOperation = MainThreadOperation(name: "Push \(element.displayName)") { [weak self] in
            guard let self = self else { return }

            let elementInspectorViewController = Self.makeElementInspectorViewController(
                element: element,
                preferredPanel: preferredPanel,
                initialPanel: self.dependencies.initialPanel,
                delegate: self,
                catalog: self.dependencies.catalog
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
    func injectElementInspectorsForViewHierarchy(
        inside navigationController: ElementInspectorNavigationController,
        dependencies: ElementInspectorDependencies
    ) {
        let allElements = [dependencies.snapshot.root] + dependencies.snapshot.root.viewHierarchy

        let populatedElements = allElements.filter { $0.underlyingObject === dependencies.rootElement.underlyingObject }

        guard let populatedElement = populatedElements.first else {
            let rootViewController = Self.makeElementInspectorViewController(
                element: dependencies.snapshot.root,
                preferredPanel: dependencies.initialPanel,
                initialPanel: dependencies.initialPanel,
                delegate: self,
                catalog: dependencies.catalog
            )

            navigationController.viewControllers = [rootViewController]

            return
        }

        navigationController.viewControllers = {
            var array = [UIViewController]()

            var element: ViewHierarchyElementReference? = populatedElement

            while element != nil {
                guard let currentElement = element else {
                    break
                }

                let viewController = Self.makeElementInspectorViewController(
                    element: currentElement,
                    preferredPanel: dependencies.initialPanel,
                    initialPanel: dependencies.initialPanel,
                    delegate: self,
                    catalog: dependencies.catalog
                )

                array.append(viewController)

                element = currentElement.parent
            }

            return array.reversed()
        }()
    }
}

extension ElementInspectorCoordinator: UIViewControllerTransitionPresenterDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
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
