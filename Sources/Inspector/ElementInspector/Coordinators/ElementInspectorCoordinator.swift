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

// MARK: - ElementInspectorCoordinatorDelegate

protocol ElementInspectorCoordinatorDelegate: AnyObject {
    func elementInspectorCoordinator(
        _ coordinator: ElementInspectorCoordinator,
        didFinishWith reference: ViewHierarchyReference
    )

    func elementInspectorCoordinator(
        _ coordinator: ElementInspectorCoordinator,
        showHighlightViewsVisibilityOf reference: ViewHierarchyReference
    )

    func elementInspectorCoordinator(
        _ coordinator: ElementInspectorCoordinator,
        hideHighlightViewsVisibilityOf reference: ViewHierarchyReference
    )

    func elementInspectorCoordinator(
        _ coordinator: ElementInspectorCoordinator,
        didSelect reference: ViewHierarchyReference,
        with action: ViewHierarchyAction?,
        from fromReference: ViewHierarchyReference
    )
}

// MARK: - ElementInspectorCoordinator

final class ElementInspectorCoordinator: NavigationCoordinator {
    weak var delegate: ElementInspectorCoordinatorDelegate?

    let snapshot: ViewHierarchySnapshot

    let rootReference: ViewHierarchyReference

    let initialAction: ViewHierarchyAction?

    weak var sourceView: UIView?

    private(set) lazy var navigationController: ElementInspectorNavigationController = {
        let navigationController = makeNavigationController(from: sourceView)

        addElementInspectorsForReferences(in: navigationController)

        return navigationController
    }()

    private(set) lazy var operationQueue = OperationQueue.main

    init(
        reference: ViewHierarchyReference,
        with action: ViewHierarchyAction?,
        in snapshot: ViewHierarchySnapshot,
        from sourceView: UIView?
    ) {
        self.rootReference = reference
        self.initialAction = action
        self.snapshot = snapshot
        self.sourceView = sourceView ?? reference.rootView
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

    func finish() {
        operationQueue.cancelAllOperations()
        operationQueue.isSuspended = true

        navigationController.dismiss(animated: true)
        delegate?.elementInspectorCoordinator(self, didFinishWith: snapshot.rootReference)
    }

    static func makeElementInspectorViewController(
        with reference: ViewHierarchyReference,
        elementLibraries: [InspectorElementLibraryProtocol],
        selectedPanel: ElementInspectorPanel?,
        delegate: ElementInspectorViewControllerDelegate,
        in snapshot: ViewHierarchySnapshot
    ) -> ElementInspectorViewController {
        ElementInspectorViewController(
            viewModel: ElementInspectorViewModel(
                snapshot: snapshot,
                reference: reference,
                selectedPanel: selectedPanel,
                inspectableElements: elementLibraries,
                availablePanels: ElementInspectorPanel.panels(for: reference.actions)
            )
        ).then {
            $0.delegate = delegate
        }
    }

    func panelViewController(for panel: ElementInspectorPanel, with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController {
        switch panel {
        case .preview:
            return ElementPreviewPanelViewController(
                viewModel: ElementPreviewPanelViewModel(
                    reference: reference,
                    isLiveUpdating: true
                )
            ).then {
                $0.delegate = self
            }

        case .attributes:
            return ElementAttributesPanelViewController(
                dataSource: DefaultFormPanelDataSource(
                    items: {
                        guard let referenceView = reference.rootView else { return [] }

                        return snapshot.elementLibraries.targeting(element: referenceView).flatMap { library in
                            library.items(for: referenceView)
                        }
                    }()
                )
            ).then {
                $0.formDelegate = self
            }

        case .children:
            return ElementChildrenPanelViewController(
                viewModel: ElementChildrenPanelViewModel(
                    reference: reference,
                    snapshot: snapshot
                )
            ).then {
                $0.delegate = self
            }

        case .size:
            let items: [ElementInspectorFormItem] = {
                guard let referenceView = reference.rootView else { return [] }

                return AutoLayoutSizeLibrary.allCases
                    .map { $0.items(for: referenceView) }
                    .flatMap { $0 }
            }()

            return ElementSizePanelViewController(
                dataSource: DefaultFormPanelDataSource(items: items) { indexPath in
                    let viewModel = items[indexPath.section].rows[indexPath.row]
                    return AutoLayoutSizeLibrary.viewType(forViewModel: viewModel)
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

    func makeNavigationController(from sourceView: UIView?) -> ElementInspectorNavigationController {
        let navigationController = ElementInspectorNavigationController()
        navigationController.dismissDelegate = self
        navigationController.setPopoverModalPresentationStyle(delegate: self, from: sourceView)

        return navigationController
    }
}

// MARK: - Private Helpers

private extension ElementInspectorCoordinator {
    func addElementInspectorsForReferences(in navigationController: ElementInspectorNavigationController) {
        let populatedReferences = snapshot.inspectableReferences.filter { $0.rootView === rootReference.rootView }

        guard let populatedReference = populatedReferences.first else {
            let rootViewController = Self.makeElementInspectorViewController(
                with: snapshot.rootReference,
                elementLibraries: snapshot.elementLibraries,
                selectedPanel: ElementInspectorPanel(rawValue: initialAction),
                delegate: self,
                in: snapshot
            )

            navigationController.viewControllers = [rootViewController]

            return
        }

        navigationController.viewControllers = {
            var array = [UIViewController]()

            var reference: ViewHierarchyReference? = populatedReference

            while reference != nil {
                guard let currentReference = reference else {
                    break
                }

                let viewController = Self.makeElementInspectorViewController(
                    with: currentReference,
                    elementLibraries: snapshot.elementLibraries,
                    selectedPanel: ElementInspectorPanel(rawValue: initialAction),
                    delegate: self,
                    in: snapshot
                )

                array.append(viewController)

                reference = currentReference.parent
            }

            return array.reversed()
        }()
    }
}
