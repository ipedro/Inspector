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

// MARK: - AttributesInspectorSectionViewDelegate

extension ElementAttributesInspectorViewController: AttributesInspectorSectionViewControllerDelegate {
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  willUpdate property: HiearchyInspectableElementProperty) {
        stopLiveUpdatingSnaphost()
    }
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didUpdate property: HiearchyInspectableElementProperty) {
        
        let updateOperation = MainThreadOperation(name: "update sections") { [weak self] in
            self?.children.forEach {
                guard let sectionViewController = $0 as? AttributesInspectorSectionViewController else {
                    return
                }
                
                sectionViewController.updateValues()
                self?.updateHeaderDetails()
            }
        }
        
        updateOperation.completionBlock = {
            DispatchQueue.main.async { [weak self] in
                self?.startLiveUpdatingSnaphost()
            }
        }
        
        delegate?.addOperationToQueue(updateOperation)
    }
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didToggle isCollapsed: Bool) {
        stopLiveUpdatingSnaphost()
        
        animatePanel(
            animations: { [weak self] in
                
                guard isCollapsed else {
                    viewController.isCollapsed.toggle()
                    return
                }

                self?.children.forEach {

                    guard let sectionViewController = $0 as? AttributesInspectorSectionViewController else {
                        return
                    }

                    if sectionViewController === viewController {
                        sectionViewController.isCollapsed = !isCollapsed
                    }
                    else {
                        sectionViewController.isCollapsed = isCollapsed
                    }

                }
                
            },
            completion: { [weak self] _ in
                self?.startLiveUpdatingSnaphost()
            }
        )
        
    }
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didTap imagePicker: ImagePreviewControl) {
        selectedImagePicker = imagePicker
        
        delegate?.attributesInspectorViewController(self, didTap: imagePicker)
    }
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didTap colorPicker: ColorPreviewControl) {
        selectedColorPicker = colorPicker
        
        delegate?.attributesInspectorViewController(self, didTap: colorPicker)
    }
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didTap optionSelector: OptionListControl) {
        selectedOptionSelector = optionSelector
        
        delegate?.attributesInspectorViewController(self, didTap: optionSelector)
    }
}
