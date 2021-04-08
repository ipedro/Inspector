//
//  ElementInspectorCoordinator+ElementInspectorAttributesInspectorViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit
import MobileCoreServices

extension ElementInspectorCoordinator: ElementInspectorAttributesInspectorViewControllerDelegate {
    
    func attributesInspectorViewController(_ viewController: ElementInspector.AttributesInspectorViewController,
                                           showLayerInspectorViewsInside reference: ViewHierarchyReference) {
        delegate?.elementInspectorCoordinator(self, showHighlightViewsVisibilityOf: reference)
    }
    
    func attributesInspectorViewController(_ viewController: ElementInspector.AttributesInspectorViewController,
                                           hideLayerInspectorViewsInside reference: ViewHierarchyReference) {
        delegate?.elementInspectorCoordinator(self, hideHighlightViewsVisibilityOf: reference)
    }
    
    func attributesInspectorViewController(_ viewController: ElementInspector.AttributesInspectorViewController, didTap colorPicker: ColorPreviewControl) {
        #if swift(>=5.3)
        if #available(iOS 14.0, *) {
            let colorPicker = UIColorPickerViewController().then {
                $0.delegate = self
                
                if let selectedColor = colorPicker.selectedColor {
                    $0.selectedColor = selectedColor
                }
                
                $0.overrideUserInterfaceStyle = .dark
                $0.modalPresentationStyle = .popover
                $0.popoverPresentationController?.sourceView = colorPicker.accessoryControl
                $0.popoverPresentationController?.permittedArrowDirections = [.up, .down]
            }
            
            viewController.present(colorPicker, animated: true)
        }
        #else
            // Xcode 11 and lower
        #endif
    }
    
    func attributesInspectorViewController(_ viewController: ElementInspector.AttributesInspectorViewController, didTap optionSelector: OptionListControl) {
        
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
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                $0.overrideUserInterfaceStyle = .dark
            }
            #endif
            
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.sourceView = optionSelector.accessoryControl
            $0.popoverPresentationController?.permittedArrowDirections = [.up, .down]
            $0.popoverPresentationController?.delegate = self
        }
        
        viewController.present(navigationController, animated: true)
    }
    
    func attributesInspectorViewController(_ viewController: ElementInspector.AttributesInspectorViewController, didTap imagePicker: ImagePreviewControl) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeImage)], in: .import).then {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                $0.overrideUserInterfaceStyle = .dark
            }
            #endif
            
            $0.view.tintColor = ElementInspector.appearance.tintColor
            $0.delegate = self
            $0.modalPresentationStyle = .popover
            $0.popoverPresentationController?.sourceView = imagePicker.accessoryControl
            $0.popoverPresentationController?.permittedArrowDirections = [.up, .down]
            $0.popoverPresentationController?.delegate = self
        }
        
        viewController.present(documentPicker, animated: true)
    }
}
