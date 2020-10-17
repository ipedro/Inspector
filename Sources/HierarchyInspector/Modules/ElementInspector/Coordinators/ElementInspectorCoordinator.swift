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
    
    init(reference: ViewHierarchyReference) {
        self.rootReference = reference
    }
    
    private(set) lazy var elementInspectorViewController = makeElementInspectorViewController(with: rootReference, showDismissBarButton: true, selectedPanel: .propertyInspector)
    
    private(set) lazy var navigationController = ElementInspectorNavigationController(rootViewController: elementInspectorViewController).then {
        $0.modalPresentationStyle = {
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
            
            return .pageSheet
        }()
        
        switch $0.modalPresentationStyle {
        case .popover:
            $0.popoverPresentationController?.sourceView = rootReference.view
            $0.popoverPresentationController?.delegate = self
            
        default:
            $0.presentationController?.delegate = self
        }
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
    
    func makeElementInspectorViewController(with reference: ViewHierarchyReference, showDismissBarButton: Bool, selectedPanel: ElementInspectorPanel?) -> ElementInspectorViewController {
        let viewModel = ElementInspectorViewModel(
            reference: reference,
            showDismissBarButton: showDismissBarButton,
            selectedPanel: selectedPanel
        )
        
        let viewController = ElementInspectorViewController.create(viewModel: viewModel)
        viewController.delegate = self
        
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
        
        delegate?.elementInspectorCoordinator(self, didFinishWith: rootReference)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ElementInspectorCoordinator: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard popoverPresentationController.presentedViewController === navigationController else {
            return
        }
        
        delegate?.elementInspectorCoordinator(self, didFinishWith: rootReference)
    }
    
}

#if swift(>=5.3)

// MARK: - UIColorPickerViewControllerDelegate

@available(iOS 14.0, *)
extension ElementInspectorCoordinator: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        topPropertyInspectorViewController?.selectColor(viewController.selectedColor)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        topPropertyInspectorViewController?.finishColorSelection()
    }
    
}

#endif

// MARK: - OptionSelectorViewControllerDelegate

extension ElementInspectorCoordinator: OptionSelectorViewControllerDelegate {
    
    func optionSelectorViewController(_ viewController: OptionSelectorViewController, didSelectIndex selectedIndex: Int?) {
        topPropertyInspectorViewController?.selectOptionAtIndex(selectedIndex)
    }
    
}

private extension ElementInspectorCoordinator {
    
    var topPropertyInspectorViewController: PropertyInspectorViewController? {
        guard let topElementInspectorViewController = navigationController.topViewController as? ElementInspectorViewController else {
            return nil
        }
        
        return topElementInspectorViewController.children.first as? PropertyInspectorViewController
    }
    
}

extension ElementInspectorCoordinator: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        for url in urls {
            guard let imageData = try? Data(contentsOf: url) else {
                continue
            }
            
            let image = UIImage(data: imageData)
            
            topPropertyInspectorViewController?.selectImage(image)
            break
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true) {
            //
        }
    }
}
