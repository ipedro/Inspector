//
//  ElementInspectorCoordinator+ElementAttributesInspectorViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit
import MobileCoreServices

extension ElementInspectorCoordinator: ElementAttributesInspectorViewControllerDelegate {
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController,
                                           showLayerInspectorViewsInside reference: ViewHierarchyReference) {
        delegate?.elementInspectorCoordinator(self, showHighlightViewsVisibilityOf: reference)
    }
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController,
                                           hideLayerInspectorViewsInside reference: ViewHierarchyReference) {
        delegate?.elementInspectorCoordinator(self, hideHighlightViewsVisibilityOf: reference)
    }
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController, didTap colorPicker: ColorPreviewControl) {
        #if swift(>=5.3)
        if #available(iOS 14.0, *) {
            let colorPickerViewController = UIColorPickerViewController(
                .colorPickerDelegate(self),
                .viewControllerOptions(
                    .overrideUserInterfaceStyle(.dark),
                    .modalPresentationStyle(.popover)
                ),
                .popoverPresentationControllerOptions(
                    .sourceView(colorPicker.accessoryControl),
                    .permittedArrowDirections([.up, .down])
                )
            )
            
            if let selectedColor = colorPicker.selectedColor {
                colorPickerViewController.selectedColor = selectedColor
            }
            
            viewController.present(colorPickerViewController, animated: true)
        }
        #endif
    }
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController,
                                           didTap optionSelector: OptionListControl) {
        
        let viewModel = OptionSelectorViewModel(
            title: optionSelector.title,
            options: optionSelector.options,
            selectedIndex: optionSelector.selectedIndex
        )
        
        let optionSelectorViewController = OptionSelectorViewController.create(viewModel: viewModel).then {
            $0.delegate = self
        }
        
        let navigationController = ElementInspectorNavigationController(
            .rootViewController(optionSelectorViewController),
            .viewControllerOptions(
                .modalPresentationStyle(.popover),
                .overrideUserInterfaceStyle(.dark)
            ),
            .popoverPresentationControllerOptions(
                .sourceView(optionSelector.accessoryControl),
                .permittedArrowDirections([.up, .down]),
                .popoverPresentationDelegate(self)
            )
        )
        
        viewController.present(navigationController, animated: true)
    }
    
    func attributesInspectorViewController(_ viewController: ElementAttributesInspectorViewController,
                                           didTap imagePicker: ImagePreviewControl) {
        let documentPicker = UIDocumentPickerViewController.forImporting(
            .documentTypes(.image),
            .asCopy(true),
            .documentPickerDelegate(self),
            .viewOptions(
                .tintColor(ElementInspector.appearance.tintColor)
            ),
            .viewControllerOptions(
                .modalPresentationStyle(.popover),
                .overrideUserInterfaceStyle(.dark)
            ),
            .popoverPresentationControllerOptions(
                .sourceView(imagePicker.accessoryControl),
                .permittedArrowDirections([.up, .down]),
                .popoverPresentationDelegate(self)
            )
        )
        
        viewController.present(documentPicker, animated: true)
    }
}
