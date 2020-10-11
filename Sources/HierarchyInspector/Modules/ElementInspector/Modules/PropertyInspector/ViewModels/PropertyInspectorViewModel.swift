//
//  PropertyInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewModelProtocol {
    var reference: ViewHierarchyReference { get}
    
    var sectionInputs: [PropertyInspectorInputSection] { get }
}

final class PropertyInspectorViewModel: PropertyInspectorViewModelProtocol {
    let reference: ViewHierarchyReference
    
    private(set) lazy var sectionInputs: [PropertyInspectorInputSection] = {
        var array = [PropertyInspectorInputSection]()
        
        if let stackView = reference.view as? UIStackView {
            array.append(.UIStackViewSection(stackView: stackView))
        }
        
        if let button = reference.view as? UIButton {
            array.append(.UIButtonSection(button: button))
        }
        
        if let control = reference.view as? UIControl {
            array.append(.UIControlSection(control: control))
        }
        
        if let activityIndicatorView = reference.view as? UIActivityIndicatorView {
            array.append(.UIActivityIndicatorViewSection(activityIndicatorView: activityIndicatorView))
        }
        
        array.append(.UIViewSection(view: reference.view))
        
        return array
    }()
    
    init(reference: ViewHierarchyReference) {
        self.reference = reference
    }
}
