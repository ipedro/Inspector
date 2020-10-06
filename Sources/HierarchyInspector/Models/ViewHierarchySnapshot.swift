//
//  ViewHierarchySnapshot.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

struct ViewHierarchySnapshot {
    
    // MARK: - Properties
    
    static var cacheExpirationTimeInSeconds: Double = 0.50
    
    let expiryDate: Date = Date().addingTimeInterval(Self.cacheExpirationTimeInSeconds)
    
    let availableLayers: [HierarchyInspector.Layer]
    
    let populatedLayers: [HierarchyInspector.Layer]
    
    let emptyLayers: [HierarchyInspector.Layer]
    
    let viewHierarchy: ViewHierarchyReference
    
    let flattenedViewHierarchy: [ViewHierarchyReference]
    
    init(availableLayers: [HierarchyInspector.Layer], in rootView: UIView) {
        self.availableLayers = availableLayers.uniqueValues
        
        viewHierarchy = ViewHierarchyReference(view: rootView)
        
        flattenedViewHierarchy = viewHierarchy.flattenedInspectableViews
        
        let inspectableViews = viewHierarchy.flattenedInspectableViews.compactMap { $0.view }
        
        populatedLayers = availableLayers.filter { $0.filter(flattenedViewHierarchy: inspectableViews).isEmpty == false }
        
        emptyLayers = Array(Set(availableLayers).subtracting(populatedLayers))
    }
    
    var inspectableViews: [UIView] {
        viewHierarchy.flattenedInspectableViews.compactMap { $0.view }
    }
}
