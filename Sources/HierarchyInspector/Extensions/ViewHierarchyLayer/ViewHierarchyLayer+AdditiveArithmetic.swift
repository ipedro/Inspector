//
//  ViewHierarchyLayer+AdditiveArithmetic.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import Foundation

// MARK: - AdditiveArithmetic

extension ViewHierarchyLayer: AdditiveArithmetic {
    
    public static func - (lhs: ViewHierarchyLayer, rhs: ViewHierarchyLayer) -> ViewHierarchyLayer {
        ViewHierarchyLayer(
            name: [lhs.name, rhs.name.localizedLowercase].joined(separator: ",-"),
            showLabels: lhs.showLabels,
            allowsSystemViews: lhs.allowsSystemViews
        ) {
            lhs.filter($0) && rhs.filter($0) == false
        }
    }
    
    public static func + (lhs: ViewHierarchyLayer, rhs: ViewHierarchyLayer) -> ViewHierarchyLayer {
        ViewHierarchyLayer(
            name: [lhs.name, rhs.name.localizedLowercase].joined(separator: ",+"),
            showLabels: lhs.showLabels,
            allowsSystemViews: lhs.allowsSystemViews
        ) {
            lhs.filter($0) || rhs.filter($0)
        }
    }
    
    public static var zero: ViewHierarchyLayer {
        ViewHierarchyLayer(name: "zero") { _ in false }
    }
    
}
