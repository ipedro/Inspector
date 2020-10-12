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
    
    private(set) lazy var elementInspectorViewController = makeElementInspectorViewController(with: rootReference, showDismissBarButton: true)
    
    private(set) lazy var navigationController = PopoverNavigationController(
        rootViewController: elementInspectorViewController
    ).then {
        
        $0.modalPresentationStyle = {
            guard let window = rootReference.view?.window else {
                return .pageSheet
            }
            
            guard window.traitCollection.userInterfaceIdiom != .phone else {
                return .pageSheet
            }
            
            let referenceViewArea = rootReference.frame.height * rootReference.frame.width
            
            let windowArea = window.frame.height * window.frame.width
            
            let ratio = referenceViewArea / windowArea
            
            if ratio < 0.4 {
                return .popover
            }
            else if ratio < 0.7 {
                return .formSheet
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
    
    func makeElementInspectorViewController(with reference: ViewHierarchyReference, showDismissBarButton: Bool) -> ElementInspectorViewController {
        let viewModel = ElementInspectorViewModel(reference: reference, showDismissBarButton: showDismissBarButton)
        
        let viewController = ElementInspectorViewController.create(viewModel: viewModel)
        viewController.delegate = self
        
        return viewController
    }
    
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ElementInspectorCoordinator: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    @available(iOS 13.0, *)
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.elementInspectorCoordinator(self, didFinishWith: rootReference)
    }
}

extension ElementInspectorCoordinator: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        delegate?.elementInspectorCoordinator(self, didFinishWith: rootReference)
    }
    
}

// MARK: - UIColorPickerViewControllerDelegate


#if swift(>=5.3)

@available(iOS 14.0, *)
extension ElementInspectorCoordinator: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        propertyInspectorViewController?.selectColor(viewController.selectedColor)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        propertyInspectorViewController?.finishColorSelection()
    }
    
}

#endif

extension ElementInspectorCoordinator: OptionSelectorViewControllerDelegate {
    
    func optionSelectorViewController(_ viewController: OptionSelectorViewController, didSelectIndex selectedIndex: Int?) {
        propertyInspectorViewController?.selectOptionAtIndex(selectedIndex)
    }
    
}

private extension ElementInspectorCoordinator {
    
    private var propertyInspectorViewController: PropertyInspectorViewController? {
        elementInspectorViewController.children.first as? PropertyInspectorViewController
    }
    
}
