//
//  PropertyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

// MARK: - PropertyInspectorSectionViewDelegate

extension PropertyInspectorViewController: PropertyInspectorSectionViewControllerDelegate {
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController, willUpdate property: PropertyInspectorSectionProperty) {
        snapshotViewCode.stopLiveUpdatingSnaphost()
    }
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController, didUpdate property: PropertyInspectorSectionProperty) {
        snapshotViewCode.startLiveUpdatingSnaphost()
    }
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController, didToggle isCollapsed: Bool) {
        snapshotViewCode.stopLiveUpdatingSnaphost()
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState,
            animations: { [weak self] in
                
                guard isCollapsed else {
                    viewController.isCollapsed.toggle()
                    return
                }
                
                self?.children.forEach {
                    
                    guard let sectionViewController = $0 as? PropertyInspectorSectionViewController else {
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
                self?.snapshotViewCode.startLiveUpdatingSnaphost()
            }
        )
        
    }
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController, didTap imagePicker: ImagePicker) {
        selectedImagePicker = imagePicker
        
        delegate?.propertyInspectorViewController(self, didTap: imagePicker)
    }
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController, didTap colorPicker: ColorPicker) {
        selectedColorPicker = colorPicker
        
        delegate?.propertyInspectorViewController(self, didTap: colorPicker)
    }
    
    func propertyInspectorSectionViewController(_ viewController: PropertyInspectorSectionViewController, didTap optionSelector: OptionSelector) {
        selectedOptionSelector = optionSelector
        
        delegate?.propertyInspectorViewController(self, didTap: optionSelector)
    }
}
