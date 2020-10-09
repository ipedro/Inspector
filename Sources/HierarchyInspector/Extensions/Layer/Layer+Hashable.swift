//
//  ViewHierarchyLayer+Hashable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import Foundation

// MARK: - Hashable

extension ViewHierarchyLayer: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
    
    public static func == (lhs: ViewHierarchyLayer, rhs: ViewHierarchyLayer) -> Bool {
        lhs.name == rhs.name
    }
    
}
