//
//  Layer.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

extension HierarchyInspector {
    
    public struct Layer {
        public typealias Filter = (UIView) -> Bool
        
        // MARK: - Properties
        
        public let name: String
        
        public let filter: Filter
        
        let showLabels: Bool
        
        let allowsInternalViews: Bool
        
        var emptyText: String {
            "No \(description) found"
        }
        
        // MARK: - Init
        
        public static func layer(name: String, filter: @escaping Filter) -> Self {
            self.init(name: name, showLabels: true, allowsInternalViews: false, filter: filter)
        }
        
        init(name: String, showLabels: Bool, allowsInternalViews: Bool = false, filter: @escaping Filter) {
            self.name = name
            self.showLabels = showLabels
            self.allowsInternalViews = allowsInternalViews
            self.filter = filter
        }
        
        // MARK: - Metods
        
        func filter(viewHierarchy: [UIView]) -> [UIView] {
            let filteredViews = viewHierarchy.filter(filter)
            
            switch allowsInternalViews {
            case true:
                return filteredViews
                
            case false:
                return filteredViews.filter { $0.isSystemView == false }
            }
        }
        
    }
    
}

// MARK: - Internal Layers

extension HierarchyInspector.Layer {
    
    static let wireframes = HierarchyInspector.Layer(name: "Wireframes", showLabels: false) { _ in true }
    
    #if DEBUG
    #warning("// TODO: investigate if this `if` clause makes sense")
    static let internalViews = HierarchyInspector.Layer(name: "Internal views", showLabels: true, allowsInternalViews: true) { $0.isSystemView }
    #endif
    
}
