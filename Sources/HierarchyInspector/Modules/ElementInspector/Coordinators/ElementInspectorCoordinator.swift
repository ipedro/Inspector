//
//  ElementInspectorCoordinator.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ElementInspectorCoordinatorDelegate: AnyObject {
    func elementInspectorCoordinatorDidFinish(_ coordinator: ElementInspectorCoordinator)
}

final class ElementInspectorCoordinator: NSObject {
    weak var delegate: ElementInspectorCoordinatorDelegate?
    
    let rootReference: ViewHierarchyReference
    
    init(reference: ViewHierarchyReference) {
        self.rootReference = reference
    }
    
    private lazy var elementInspectorViewController = makeElementInspectorViewController(with: rootReference)
    
    private lazy var navigationController = PopoverNavigationController(
        rootViewController: elementInspectorViewController
    ).then {
        $0.presentationDelegate = self
        $0.modalPresentationStyle = .popover
        $0.popoverPresentationController?.sourceView = rootReference.view
    }
    
    private var permittedPopoverArrowDirections: UIPopoverArrowDirection {
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
    
    private func makeElementInspectorViewController(with reference: ViewHierarchyReference) -> ElementInspectorViewController {
        let viewModel = ElementInspectorViewModel(reference: reference)
        
        let viewController = ElementInspectorViewController.create(viewModel: viewModel)
        viewController.delegate = self
        
        return viewController
    }
    
}

extension ElementInspectorCoordinator: PopoverNavigationControllerDelegate {
    func popoverNavigationControllerDidFinish(_ popoverNavigationController: PopoverNavigationController) {
        guard popoverNavigationController.topViewController === elementInspectorViewController else {
            return
        }
        
        delegate?.elementInspectorCoordinatorDidFinish(self)
    }
}

// MARK: - ElementInspectorViewControllerDelegate

extension ElementInspectorCoordinator: ElementInspectorViewControllerDelegate {
    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        viewControllerForPanel panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> UIViewController {
        switch panel {
        
        case .propertyInspector:
            return PropertyInspectorViewController.create(viewModel: PropertyInspectorViewModel(reference: reference)).then {
                $0.delegate = self
            }
            
        case .viewHierarchy:
            return ViewHierarchyListViewController.create(viewModel: ViewHierarchyListViewModel(reference: reference)).then {
                $0.delegate = self
            }
            
        }
    }
}

extension ElementInspectorCoordinator: ViewHierarchyListViewControllerDelegate {
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSelect reference: ViewHierarchyReference) {
        let elementInspectorViewController = makeElementInspectorViewController(with: reference)
        
        navigationController.pushViewController(elementInspectorViewController, animated: true)
    }
}

// MARK: - PropertyInspectorViewControllerDelegate

extension ElementInspectorCoordinator: PropertyInspectorViewControllerDelegate {
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTapColorPicker colorPicker: ColorPicker) {
        #if swift(>=5.3)
        if #available(iOS 14.0, *) {
            let colorPicker = UIColorPickerViewController().then {
                $0.delegate = self
                
                if let selectedColor = colorPicker.selectedColor {
                    $0.selectedColor = selectedColor
                }
                
                $0.overrideUserInterfaceStyle = navigationController.overrideUserInterfaceStyle
                $0.modalPresentationStyle = .popover
                $0.popoverPresentationController?.sourceView = colorPicker
                $0.popoverPresentationController?.permittedArrowDirections = permittedPopoverArrowDirections
            }
            
            viewController.present(colorPicker, animated: true)
        }
        #else
            // Xcode 11 and lower
        #endif
    }
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTapOptionSelector optionSelector: OptionSelector) {
        
        let viewModel = OptionSelectorViewModel(
            title: optionSelector.title,
            options: optionSelector.options,
            selectedIndex: optionSelector.selectedIndex
        )
        
        let optionSelectorViewController = OptionSelectorViewController.create(viewModel: viewModel).then {
            $0.delegate = self
        }
        
        let navigationController = PopoverNavigationController(
            rootViewController: optionSelectorViewController
        ).then {
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.sourceView = optionSelector
            $0.popoverPresentationController?.permittedArrowDirections = permittedPopoverArrowDirections
            $0.popoverPresentationController?.delegate = self
        }
        
        viewController.present(navigationController, animated: true)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ElementInspectorCoordinator: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
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
