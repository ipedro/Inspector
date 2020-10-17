//
//  PropertyInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewModelProtocol {
    var reference: ViewHierarchyReference { get}
    
    var sectionViewModels: [PropertyInspectorSectionViewModelProtocol] { get }
}

final class PropertyInspectorViewModel: PropertyInspectorViewModelProtocol {
    let reference: ViewHierarchyReference
    
    private(set) lazy var sectionViewModels: [PropertyInspectorSectionViewModelProtocol] = {
        var array = [PropertyInspectorSectionViewModelProtocol]()
        
        if let stackView = reference.view as? UIStackView {
            array.append(PropertyInspectorSectionUIStackViewViewModel(stackView: stackView))
        }
        
        if let button = reference.view as? UIButton {
            array.append(PropertyInspectorSectionUIButtonViewModel(button: button))
        }
        
        if let slider = reference.view as? UISlider {
            array.append(PropertyInspectorSectionUISliderViewModel(slider: slider))
        }
        
        if let switchControl = reference.view as? UISwitch {
            array.append(PropertyInspectorSectionUISwitchViewModel(switchControl: switchControl))
        }
        
        if let control = reference.view as? UIControl {
            array.append(PropertyInspectorSectionUIControlViewModel(control: control))
        }
        
        if let activityIndicatorView = reference.view as? UIActivityIndicatorView {
            array.append(PropertyInspectorSectionUIActivityIndicatorViewViewModel(activityIndicatorView: activityIndicatorView))
        }
        
        if let imageView = reference.view as? UIImageView {
            array.append(PropertyInspectorSectionUIImageViewViewModel(imageView: imageView))
        }
        
        if let label = reference.view as? UILabel {
            array.append(PropertyInspectorSectionUILabelViewModel(label: label))
        }
        
        if let view = reference.view {
            array.append(PropertyInspectorSectionUIViewViewModel(view: view))
        }
        
        return array
    }()
    
    init(reference: ViewHierarchyReference) {
        self.reference = reference
    }
}
