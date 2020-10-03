//
//  Layer+Hashable.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import Foundation

// MARK: - Hashable

extension HierarchyInspector.Layer: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
    
    public static func == (lhs: HierarchyInspector.Layer, rhs: HierarchyInspector.Layer) -> Bool {
        lhs.name == rhs.name
    }
    
}
