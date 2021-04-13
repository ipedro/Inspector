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
            animations: {
                
                viewController.isCollapsed.toggle()
                
//                guard isCollapsed else {
//                    viewController.isCollapsed.toggle()
//                    return
//                }
//
//                self?.children.forEach {
//
//                    guard let sectionViewController = $0 as? AttributesInspectorSectionViewController else {
//                        return
//                    }
//
//                    if sectionViewController === viewController {
//                        sectionViewController.isCollapsed = !isCollapsed
//                    }
//                    else {
//                        sectionViewController.isCollapsed = isCollapsed
//                    }
//
//                }
                
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
