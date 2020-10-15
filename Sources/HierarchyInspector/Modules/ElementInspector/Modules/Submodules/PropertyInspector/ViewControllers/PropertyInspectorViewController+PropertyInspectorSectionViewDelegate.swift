//
//  PropertyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

// MARK: - PropertyInspectorSectionViewDelegate

extension PropertyInspectorViewController: PropertyInspectorSectionViewDelegate {
    
    func propertyInspectorSectionViewWillUpdateProperty(_ section: PropertyInspectorSectionView) {
        snapshotViewCode.stopLiveUpdatingSnaphost()
    }
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didUpdate property: PropertyInspectorInput) {
        snapshotViewCode.startLiveUpdatingSnaphost()
    }
    
    func propertyInspectorSectionViewDidTapHeader(_ section: PropertyInspectorSectionView, isCollapsed: Bool) {
        snapshotViewCode.stopLiveUpdatingSnaphost()
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState,
            animations: { [weak self] in
                
                guard isCollapsed else {
                    section.isCollapsed.toggle()
                    return
                }
                
                self?.sectionViews.forEach {
                    if $0 === section {
                        $0.isCollapsed = !isCollapsed
                    }
                    else {
                        $0.isCollapsed = isCollapsed
                    }
                }
                
                
            },
            completion: { [weak self] _ in
                self?.snapshotViewCode.startLiveUpdatingSnaphost()
            }
        )
        
    }
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTap imagePicker: ImagePicker) {
        selectedImagePicker = imagePicker
        
        delegate?.propertyInspectorViewController(self, didTap: imagePicker)
    }
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTap colorPicker: ColorPicker) {
        selectedColorPicker = colorPicker
        
        delegate?.propertyInspectorViewController(self, didTap: colorPicker)
    }
    
    func propertyInspectorSectionView(_ section: PropertyInspectorSectionView, didTap optionSelector: OptionSelector) {
        selectedOptionSelector = optionSelector
        
        delegate?.propertyInspectorViewController(self, didTap: optionSelector)
    }
}
