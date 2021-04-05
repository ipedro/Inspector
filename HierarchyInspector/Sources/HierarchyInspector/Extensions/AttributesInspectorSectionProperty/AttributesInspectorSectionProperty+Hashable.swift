//
//  AttributesInspectorSectionProperty+Hashable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 06.12.20.
//

import Foundation

extension AttributesInspectorSectionProperty: Hashable {
    
    private var idenfitifer: String {
        String(describing: self)
    }
    
    static func == (lhs: AttributesInspectorSectionProperty, rhs: AttributesInspectorSectionProperty) -> Bool {
        lhs.idenfitifer == rhs.idenfitifer
    }
    
    func hash(into hasher: inout Hasher) {
        idenfitifer.hash(into: &hasher)
    }
    
}
