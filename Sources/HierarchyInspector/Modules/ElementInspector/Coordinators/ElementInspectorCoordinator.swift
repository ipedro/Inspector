//
//  ElementInspectorCoordinator.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ElementInspectorCoordinator: NSObject {
    
    let reference: ViewHierarchyReference
    
    weak var sourceView: UIView?
    
    init(reference: ViewHierarchyReference, sourceView: UIView) {
        self.reference = reference
        self.sourceView = sourceView
    }
    
    private lazy var elementInspectorViewController: ElementInspectorViewController = {
        let viewModel = ElementInspectorViewModel(reference: reference)
        
        let viewController = ElementInspectorViewController.create(viewModel: viewModel)
        viewController.delegate = self

        return viewController
    }()
    
    private lazy var navigationController = UINavigationController(
        rootViewController: elementInspectorViewController
    ).then {
        $0.modalPresentationStyle = .popover
        $0.popoverPresentationController?.sourceView = sourceView
        $0.popoverPresentationController?.delegate = self
        
        if #available(iOS 13.0, *) {
            $0.view.backgroundColor = .systemBackground
        } else {
            $0.view.backgroundColor = .groupTableViewBackground
        }
    }
    
    func start() -> UINavigationController {
        navigationController
    }
}

// MARK: - ElementInspectorViewControllerDelegate

extension ElementInspectorCoordinator: ElementInspectorViewControllerDelegate {
    func elementInspectorViewController(_ viewController: ElementInspectorViewController, viewControllerForPanel panel: ElementInspectorPanel) -> UIViewController {
        switch panel {
        
        case .propertyInspector:
            return PropertyInspectorViewController.create(
                viewModel: PropertyInspectorViewModel(
                    reference: reference
                )
            ).then {
                $0.delegate = self
            }
            
        case .viewHierarchy:
            return ViewHierarchyListViewController.create(
                viewModel: ViewHierarchyListViewModel(
                    reference: reference
                )
            )
        }
    }
}

// MARK: - PropertyInspectorViewControllerDelegate

extension ElementInspectorCoordinator: PropertyInspectorViewControllerDelegate {
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTapColorPicker colorPicker: ColorPicker, sourceRect: CGRect) {
        #if swift(>=5.3)
        if #available(iOS 14.0, *) {
            let colorPicker = UIColorPickerViewController().then {
                $0.delegate = self
                $0.selectedColor = colorPicker.selectedColor
                $0.modalPresentationStyle = .popover
                $0.popoverPresentationController?.sourceView = colorPicker.valueContainerView
                $0.popoverPresentationController?.permittedArrowDirections = [.up, .down]
            }
            
            viewController.present(colorPicker, animated: true)
        }
        #else
            // Xcode 11
        #endif
    }
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTapOptionSelector optionSelector: OptionSelector, sourceRect: CGRect) {
        
        let viewModel = OptionSelectorViewModel(
            title: optionSelector.title,
            options: optionSelector.options,
            selectedIndex: optionSelector.selectedIndex
        )
        
        let optionSelectorViewController = OptionSelectorViewController.create(viewModel: viewModel).then {
            $0.delegate = self
        }
        
        let navigationController = UINavigationController(rootViewController: optionSelectorViewController).then {
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.sourceView = optionSelector.valueContainerView
            $0.popoverPresentationController?.delegate = self
            $0.popoverPresentationController?.permittedArrowDirections = [.up, .down]
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
