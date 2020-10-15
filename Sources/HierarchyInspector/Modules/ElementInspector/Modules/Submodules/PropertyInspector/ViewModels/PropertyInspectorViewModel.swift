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
            array.append(PropertyInspectorUIStackViewSectionViewModel(stackView: stackView))
        }
        
        if let button = reference.view as? UIButton {
            array.append(PropertyInspectorUIButtonSectionViewModel(button: button))
        }
        
        if let switchControl = reference.view as? UISwitch {
            array.append(PropertyInspectorUISwitchSectionViewModel(switchControl: switchControl))
        }
        
        if let control = reference.view as? UIControl {
            array.append(PropertyInspectorUIControlSectionViewModel(control: control))
        }
        
        if let activityIndicatorView = reference.view as? UIActivityIndicatorView {
            array.append(PropertyInspectorUIActivityIndicatorViewSectionViewModel(activityIndicatorView: activityIndicatorView))
        }
        
        if let view = reference.view {
            array.append(PropertyInspectorUIViewSectionViewModel(view: view))
        }
        
        return array
    }()
    
    init(reference: ViewHierarchyReference) {
        self.reference = reference
    }
}
