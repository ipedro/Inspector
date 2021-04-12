//
//  HiearchyInspectableElementProperty+Hashable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 06.12.20.
//

import Foundation

extension HiearchyInspectableElementProperty: Hashable {
    
    private var idenfitifer: String {
        String(describing: self)
    }
    
    public static func == (
        lhs: HiearchyInspectableElementProperty,
        rhs: HiearchyInspectableElementProperty
    ) -> Bool {
        lhs.idenfitifer == rhs.idenfitifer
    }
    
    public func hash(into hasher: inout Hasher) {
        idenfitifer.hash(into: &hasher)
    }
    
}
