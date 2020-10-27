//
//  ElementInspectorCoordinator+PropertyInspectorViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit
import MobileCoreServices

// MARK: - PropertyInspectorViewControllerDelegate

extension ElementInspectorCoordinator: PropertyInspectorViewControllerDelegate {
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         showLayerInspectorViewsInside reference: ViewHierarchyReference) {
        delegate?.elementInspectorCoordinator(self, showHighlightViewsVisibilityOf: reference)
    }
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController,
                                         hideLayerInspectorViewsInside reference: ViewHierarchyReference) {
        delegate?.elementInspectorCoordinator(self, hideHighlightViewsVisibilityOf: reference)
    }
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTap colorPicker: ColorPicker) {
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
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTap optionSelector: OptionSelector) {
        
        let viewModel = OptionSelectorViewModel(
            title: optionSelector.title,
            options: optionSelector.options,
            selectedIndex: optionSelector.selectedIndex
        )
        
        let optionSelectorViewController = OptionSelectorViewController.create(viewModel: viewModel).then {
            $0.delegate = self
        }
        
        let navigationController = ElementInspectorNavigationController(
            rootViewController: optionSelectorViewController
        ).then {
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.sourceView = optionSelector
            $0.popoverPresentationController?.permittedArrowDirections = permittedPopoverArrowDirections
            $0.popoverPresentationController?.delegate = self
        }
        
        viewController.present(navigationController, animated: true)
    }
    
    func propertyInspectorViewController(_ viewController: PropertyInspectorViewController, didTap imagePicker: ImagePicker) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeImage)], in: .import).then {
            if #available(iOS 13.0, *) {
                $0.overrideUserInterfaceStyle = navigationController.overrideUserInterfaceStyle
            }
            
            $0.view.tintColor = ElementInspector.configuration.appearance.tintColor
            $0.delegate = self
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.sourceView = imagePicker
            $0.popoverPresentationController?.permittedArrowDirections = permittedPopoverArrowDirections
            $0.popoverPresentationController?.delegate = self
        }
        
        viewController.present(documentPicker, animated: true)
    }
}
