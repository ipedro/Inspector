//
//  ElementAttributesInspectorViewController+AttributesInspectorSectionViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

// MARK: - AttributesInspectorSectionViewDelegate

extension ElementAttributesInspectorViewController: AttributesInspectorSectionViewControllerDelegate {
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  willUpdate property: HiearchyInspectableElementProperty) {
        displayLink?.isPaused = true
    }
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didUpdate property: HiearchyInspectableElementProperty) {
        
        let updateOperation = MainThreadOperation(name: "update sections") { [weak self] in
            self?.children.forEach {
                guard let sectionViewController = $0 as? AttributesInspectorSectionViewController else {
                    return
                }
                
                sectionViewController.updateValues()
            }
        }
        
        updateOperation.completionBlock = { [weak self] in
            self?.displayLink?.isPaused = false
        }
        
        delegate?.addOperationToQueue(updateOperation)
    }
    
    func attributesInspectorSectionViewController(_ viewController: AttributesInspectorSectionViewController,
                                                  didToggle isCollapsed: Bool) {
        displayLink?.isPaused = true
        
        UIView.animate(
            withDuration: 0.55,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState,
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
                self?.displayLink?.isPaused = false
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
