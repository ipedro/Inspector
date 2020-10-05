//
//  ViewHierarchySnapshot.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

struct ViewHierarchySnapshot {
    
    // MARK: - Properties
    
    static var cacheExpirationTimeInSeconds: Double = 5
    
    let expiryDate: Date = Date().addingTimeInterval(Self.cacheExpirationTimeInSeconds)
    
    let availableLayers: [HierarchyInspector.Layer]
    
    let populatedLayers: [HierarchyInspector.Layer]
    
    let emptyLayers: [HierarchyInspector.Layer]
    
    let rootReference: ViewHierarchyReference
    
    let inspectableViewHierarchy: [ViewHierarchyReference]
    
    init(availableLayers: [HierarchyInspector.Layer], in rootView: UIView) {
        self.availableLayers = availableLayers
        
        rootReference = ViewHierarchyReference(view: rootView)
        
        inspectableViewHierarchy = rootReference.inspectableViewHierarchy
        
        let inspectableViews = rootReference.inspectableViewHierarchy.compactMap { $0.view }
        
        populatedLayers = availableLayers.filter { $0.filter(viewHierarchy: inspectableViews).isEmpty == false }
        
        emptyLayers = Array(Set(availableLayers).subtracting(populatedLayers))
    }
    
    var inspectableViews: [UIView] {
        rootReference.inspectableViewHierarchy.compactMap { $0.view }
    }
}
