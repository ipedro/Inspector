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
        
        let allowsSystemViews: Bool
        
        var emptyActionTitle: String {
            "No \(description) found"
        }
        
        // MARK: - Init
        
        public static func layer(name: String, filter: @escaping Filter) -> Self {
            self.init(name: name, showLabels: true, allowsSystemViews: false, filter: filter)
        }
        
        init(name: String, showLabels: Bool, allowsSystemViews: Bool = false, filter: @escaping Filter) {
            self.name = name
            self.showLabels = showLabels
            self.allowsSystemViews = allowsSystemViews
            self.filter = filter
        }
        
        // MARK: - Metods
        
        func filter(snapshot: ViewHierarchySnapshot) -> [UIView] {
            let inspectableViews = snapshot.inspectableViewHierarchy.compactMap { $0.view }
            
            return filter(viewHierarchy: inspectableViews)
        }

        func filter(viewHierarchy: [UIView]) -> [UIView] {
            let filteredViews = viewHierarchy.filter(filter)
            
            switch allowsSystemViews {
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
    #warning("TODO: investigate if this `if` clause makes sense")
    static let internalViews = HierarchyInspector.Layer(name: "Internal views", showLabels: true, allowsSystemViews: true) { $0.isSystemView }
    #endif
    
}
