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

protocol ElementInspectorCoordinatorDelegate: AnyObject {
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator,
                                     didFinishWith reference: ViewHierarchyReference)
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator,
                                     showHighlightViewsVisibilityOf reference: ViewHierarchyReference)
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator,
                                     hideHighlightViewsVisibilityOf reference: ViewHierarchyReference)
}

final class ElementInspectorCoordinator: NSObject {
    weak var delegate: ElementInspectorCoordinatorDelegate?
    
    let viewHierarchySnapshot: ViewHierarchySnapshot
    
    let reference: ViewHierarchyReference
    
    weak var sourceView: UIView?
    
    private(set) lazy var navigationController = Self.makeNavigationController(
        reference: reference,
        viewHierarchySnapshot: viewHierarchySnapshot,
        delegate: self
    ).then {
        $0.dismissDelegate = self
        
        switch $0.modalPresentationStyle {
        case .popover:
            $0.popoverPresentationController?.delegate = self
            $0.popoverPresentationController?.sourceView = sourceView
            
        default:
            $0.presentationController?.delegate = self
        }
    }
    
    private(set) lazy var operationQueue = OperationQueue.main
    
    init(
        reference: ViewHierarchyReference,
        in viewHierarchySnapshot: ViewHierarchySnapshot,
        from sourceView: UIView?
    ) {
        self.reference = reference
        self.viewHierarchySnapshot = viewHierarchySnapshot
        self.sourceView = sourceView ?? reference.rootView
    }
    
    static func makeNavigationController(
        reference: ViewHierarchyReference,
        viewHierarchySnapshot: ViewHierarchySnapshot,
        delegate: ElementInspectorViewControllerDelegate
    ) -> ElementInspectorNavigationController {
        let navigationController = ElementInspectorNavigationController()
        navigationController.modalPresentationStyle = {
            guard let window = viewHierarchySnapshot.rootReference.rootView else {
                return .pageSheet
            }
            
            guard window.traitCollection.userInterfaceIdiom != .phone else {
                return .pageSheet
            }
            
            let referenceViewArea = viewHierarchySnapshot.rootReference.frame.height * viewHierarchySnapshot.rootReference.frame.width
            
            let windowArea = window.frame.height * window.frame.width
            
            let occupiedRatio = referenceViewArea / windowArea
            
            if occupiedRatio <= 0.35 {
                return .popover
            }
            
            return .formSheet
        }()

        if ElementInspector.configuration.isPresentingFromBottomSheet {
            #if swift(>=5.5)
            if #available(iOS 15.0, *) {
                if let sheetPresentationController = navigationController.presentationController as? UISheetPresentationController {
                    sheetPresentationController.detents = [.medium(), .large()]
                    sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheetPresentationController.prefersEdgeAttachedInCompactHeight = true
                }
            }
            #endif
        }
        
        let populatedReferences = viewHierarchySnapshot.inspectableReferences.filter { $0.rootView === reference.rootView }

        let selectedPanel: ElementInspectorPanel = .preview

        guard let populatedReference = populatedReferences.first else {
            let rootViewController = makeElementInspectorViewController(
                with: viewHierarchySnapshot.rootReference,
                in: viewHierarchySnapshot,
                selectedPanel: selectedPanel,
                elementLibraries: viewHierarchySnapshot.elementLibraries,
                delegate: delegate
            )
            
            navigationController.viewControllers = [rootViewController]
            
            return navigationController
        }
        
        navigationController.viewControllers = {
            var array = [UIViewController]()
            
            var reference: ViewHierarchyReference? = populatedReference
            
            while reference != nil {
                guard let currentReference = reference else {
                    break
                }
                
                let viewController = makeElementInspectorViewController(
                    with: currentReference,
                    in: viewHierarchySnapshot,
                    selectedPanel: selectedPanel,
                    elementLibraries: viewHierarchySnapshot.elementLibraries,
                    delegate: delegate
                )
                
                array.append(viewController)
                
                reference = currentReference.parent
            }
            
            return array.reversed()
        }()
        
        return navigationController
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
    
    func start() -> UIViewController {
        navigationController
    }
    
    func finish() {
        operationQueue.cancelAllOperations()
        operationQueue.isSuspended = true
        
        delegate?.elementInspectorCoordinator(self, didFinishWith: viewHierarchySnapshot.rootReference)
    }
    
    static func makeElementInspectorViewController(
        with reference: ViewHierarchyReference,
        in snapshot: ViewHierarchySnapshot,
        selectedPanel: ElementInspectorPanel?,
        elementLibraries: [InspectorElementLibraryProtocol],
        delegate: ElementInspectorViewControllerDelegate
    ) -> ElementInspectorViewController {
        let viewModel = ElementInspectorViewModel(
            snapshot: snapshot,
            reference: reference,
            selectedPanel: selectedPanel,
            inspectableElements: elementLibraries,
            availablePanels: ElementInspectorPanel.cases(for: reference)
        )
        
        let viewController = ElementInspectorViewController(viewModel: viewModel)
        viewController.delegate = delegate
        
        return viewController
    }

    

    func panelViewController(for panel: ElementInspectorPanel, with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController {
        switch panel {
        case .preview:
            return ElementPreviewPanelViewController.create(
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

                        return viewHierarchySnapshot.elementLibraries.targeting(element: referenceView).flatMap { library in
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
                    snapshot: viewHierarchySnapshot
                )
            ).then {
                $0.delegate = self
            }

        case .size:
            let items: [ElementInspectorFormItem] = {
                guard let referenceView = reference.rootView else { return [] }

                return AutoLayoutSizeLibrary.allCases
                    .map{ $0.items(for: referenceView) }
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

    var topAttributesInspectorViewController: ElementAttributesPanelViewController? {
        guard let topElementInspectorViewController = navigationController.topViewController as? ElementInspectorViewController else {
            return nil
        }

        return topElementInspectorViewController.children.first as? ElementAttributesPanelViewController
    }
}

final class ElementAttributesPanelViewController: ElementInspectorFormPanelViewController {}

final class ElementSizePanelViewController: ElementInspectorFormPanelViewController {}
