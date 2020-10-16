//
//  PropertyInspectorSectionViewModelProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import Foundation

protocol PropertyInspectorSectionViewModelProtocol: AnyObject {
    
    var title: String? { get }
    
    var propertyInputs: [PropertyInspectorSectionInput] { get }
    
}
