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
