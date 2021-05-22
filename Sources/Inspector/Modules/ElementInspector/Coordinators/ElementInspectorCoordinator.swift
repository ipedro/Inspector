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
        
        let populatedReferences = viewHierarchySnapshot.inspectableReferences.filter { $0.rootView === reference.rootView }
        
        guard let populatedReference = populatedReferences.first else {
            let rootViewController = makeElementInspectorViewController(
                with: viewHierarchySnapshot.rootReference,
                showDismissBarButton: true,
                selectedPanel: .attributesInspector,
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
                    showDismissBarButton: currentReference === viewHierarchySnapshot.rootReference,
                    selectedPanel: .attributesInspector,
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
        showDismissBarButton: Bool,
        selectedPanel: ElementInspectorPanel?,
        elementLibraries: [InspectorElementLibraryProtocol],
        delegate: ElementInspectorViewControllerDelegate
    ) -> ElementInspectorViewController {
        
        let viewModel = ElementInspectorViewModel(
            reference: reference,
            showDismissBarButton: showDismissBarButton,
            selectedPanel: selectedPanel,
            inspectableElements: elementLibraries
        )
        
        let viewController = ElementInspectorViewController.create(viewModel: viewModel)
        viewController.delegate = delegate
        
        return viewController
    }
    
}

extension ElementInspectorCoordinator: ElementInspectorNavigationControllerDismissDelegate {
    func elementInspectorNavigationControllerDidFinish(_ navigationController: ElementInspectorNavigationController) {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension ElementInspectorCoordinator: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    @available(iOS 13.0, *)
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard presentationController.presentedViewController === navigationController else {
            return
        }
        
        finish()
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ElementInspectorCoordinator: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard popoverPresentationController.presentedViewController === navigationController else {
            return
        }
        
        finish()
    }
    
}

#if swift(>=5.3)

// MARK: - UIColorPickerViewControllerDelegate

@available(iOS 14.0, *)
extension ElementInspectorCoordinator: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        topAttributesInspectorViewController?.selectColor(viewController.selectedColor)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        topAttributesInspectorViewController?.finishColorSelection()
    }
    
}

#endif

// MARK: - OptionSelectorViewControllerDelegate

extension ElementInspectorCoordinator: OptionSelectorViewControllerDelegate {
    
    func optionSelectorViewController(_ viewController: OptionSelectorViewController, didSelectIndex selectedIndex: Int?) {
        topAttributesInspectorViewController?.selectOptionAtIndex(selectedIndex)
    }
    
}

private extension ElementInspectorCoordinator {
    
    var topAttributesInspectorViewController: ElementAttributesInspectorViewController? {
        guard let topElementInspectorViewController = navigationController.topViewController as? ElementInspectorViewController else {
            return nil
        }
        
        return topElementInspectorViewController.children.first as? ElementAttributesInspectorViewController
    }
    
}

// MARK: - UIDocumentPickerDelegate

extension ElementInspectorCoordinator: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        for url in urls {
            guard let imageData = try? Data(contentsOf: url) else {
                continue
            }
            
            let image = UIImage(data: imageData)
            
            topAttributesInspectorViewController?.selectImage(image)
            break
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}

// MARK: - OperationQueueManagerProtocol

extension ElementInspectorCoordinator: OperationQueueManagerProtocol {
    
    func cancelAllOperations() {
        operationQueue.cancelAllOperations()
    }
    
    func addOperationToQueue(_ operation: MainThreadOperation) {
        guard operationQueue.operations.contains(operation) == false else {
            return
        }
        
        operationQueue.addOperation(operation)
    }
    
    func suspendQueue(_ isSuspended: Bool) {
        operationQueue.isSuspended = isSuspended
    }
    
}
