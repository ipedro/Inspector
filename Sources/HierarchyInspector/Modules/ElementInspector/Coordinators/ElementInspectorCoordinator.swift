//
//  ElementInspectorCoordinator.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

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
    
    let rootReference: ViewHierarchyReference
    
    let reference: ViewHierarchyReference
    
    private(set) lazy var navigationController = Self.makeNavigationController(
        reference: reference,
        rootReference: rootReference,
        delegate: self
    ).then {
        switch $0.modalPresentationStyle {
        case .popover:
            $0.popoverPresentationController?.delegate = self
            
        default:
            $0.presentationController?.delegate = self
        }
    }
    
    private(set) lazy var operationQueue = OperationQueue.main
    
    init(reference: ViewHierarchyReference, rootReference: ViewHierarchyReference) {
        self.rootReference = rootReference
        self.reference = reference
    }
    
    static func makeNavigationController(
        reference: ViewHierarchyReference,
        rootReference: ViewHierarchyReference,
        delegate: ElementInspectorViewControllerDelegate
    ) -> ElementInspectorNavigationController {
        let navigationController = ElementInspectorNavigationController()
        navigationController.modalPresentationStyle = {
            guard let window = rootReference.view?.window else {
                return .pageSheet
            }
            
            guard window.traitCollection.userInterfaceIdiom != .phone else {
                return .pageSheet
            }
            
            let referenceViewArea = rootReference.frame.height * rootReference.frame.width
            
            let windowArea = window.frame.height * window.frame.width
            
            let occupiedRatio = referenceViewArea / windowArea
            
            if occupiedRatio <= 0.35 {
                return .popover
            }
            
            return .formSheet
        }()
        
        switch navigationController.modalPresentationStyle {
        case .popover:
            navigationController.popoverPresentationController?.sourceView = rootReference.view
            
        default:
            break
        }
        
        let populatedReferences = rootReference.flattenedViewHierarchy.filter { $0.view === reference.view }
        
        guard let populatedReference = populatedReferences.first else {
            let rootViewController = makeElementInspectorViewController(
                with: rootReference,
                showDismissBarButton: true,
                selectedPanel: .attributesInspector,
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
                    showDismissBarButton: currentReference === rootReference,
                    selectedPanel: .attributesInspector,
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
    
    func start() -> UINavigationController {
        navigationController
    }
    
    func finish() {
        operationQueue.cancelAllOperations()
        operationQueue.isSuspended = true
        
        delegate?.elementInspectorCoordinator(self, didFinishWith: rootReference)
    }
    
    static func makeElementInspectorViewController(
        with reference: ViewHierarchyReference,
        showDismissBarButton: Bool, selectedPanel: ElementInspectorPanel?,
        delegate: ElementInspectorViewControllerDelegate
    ) -> ElementInspectorViewController {
        
        let viewModel = ElementInspectorViewModel(
            reference: reference,
            showDismissBarButton: showDismissBarButton,
            selectedPanel: selectedPanel
        )
        
        let viewController = ElementInspectorViewController.create(viewModel: viewModel)
        viewController.delegate = delegate
        
        return viewController
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension ElementInspectorCoordinator: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    @available(iOS 13.0, *)
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
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
    
    var topAttributesInspectorViewController: ElementInspector.AttributesInspectorViewController? {
        guard let topElementInspectorViewController = navigationController.topViewController as? ElementInspectorViewController else {
            return nil
        }
        
        return topElementInspectorViewController.children.first as? ElementInspector.AttributesInspectorViewController
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
