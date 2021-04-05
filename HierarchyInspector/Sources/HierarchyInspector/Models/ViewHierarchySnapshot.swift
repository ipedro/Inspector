//
//  ViewHierarchySnapshot.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

struct ViewHierarchySnapshot {
    
    // MARK: - Properties
    
    static var cacheExpirationTimeInterval: TimeInterval = 0.5
    
    let expiryDate: Date = Date().addingTimeInterval(Self.cacheExpirationTimeInterval)
    
    let availableLayers: [ViewHierarchyLayer]
    
    let populatedLayers: [ViewHierarchyLayer]
    
    let emptyLayers: [ViewHierarchyLayer]
    
    let viewHierarchy: ViewHierarchyReference
    
    let flattenedViewHierarchy: [ViewHierarchyReference]
    
    init(availableLayers: [ViewHierarchyLayer], in rootView: UIView) {
        self.availableLayers = availableLayers.uniqueValues
        
        viewHierarchy = ViewHierarchyReference(root: rootView)
        
        flattenedViewHierarchy = viewHierarchy.flattenedInspectableViews
        
        let inspectableViews = viewHierarchy.flattenedInspectableViews.compactMap { $0.view }
        
        populatedLayers = availableLayers.filter { $0.filter(flattenedViewHierarchy: inspectableViews).isEmpty == false }
        
        emptyLayers = Array(Set(availableLayers).subtracting(populatedLayers))
    }
    
    var inspectableViews: [UIView] {
        viewHierarchy.flattenedInspectableViews.compactMap { $0.view }
    }
}
