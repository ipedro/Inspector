//
//  Layer+AdditiveArithmetic.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import Foundation

// MARK: - AdditiveArithmetic

extension HierarchyInspector.Layer: AdditiveArithmetic {
    
    public static func - (lhs: HierarchyInspector.Layer, rhs: HierarchyInspector.Layer) -> HierarchyInspector.Layer {
        HierarchyInspector.Layer(name: [lhs.name, rhs.name.localizedLowercase].joined(separator: ",-"), showLabels: lhs.showLabels) {
            lhs.filter($0) && rhs.filter($0) == false
        }
    }
    
    public static func + (lhs: HierarchyInspector.Layer, rhs: HierarchyInspector.Layer) -> HierarchyInspector.Layer {
        HierarchyInspector.Layer(name: [lhs.name, rhs.name.localizedLowercase].joined(separator: ",+"), showLabels: lhs.showLabels) {
            lhs.filter($0) || rhs.filter($0)
        }
    }
    
    public static var zero: HierarchyInspector.Layer {
        HierarchyInspector.Layer(name: "zero") { _ in false }
    }
    
}
