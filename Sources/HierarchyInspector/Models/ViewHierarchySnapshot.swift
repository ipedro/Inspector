//
//  ViewHierarchySnapshot.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import Foundation

struct ViewHierarchySnapshot {
    
    // MARK: - Properties
    
    static var cacheExpirationTimeInSeconds: Double = 5
    
    let availableLayers: [HierarchyInspector.Layer]
    
    let populatedLayers: [HierarchyInspector.Layer]
    
    var emptyLayers: [HierarchyInspector.Layer] {
        Array(Set(availableLayers).subtracting(populatedLayers))
    }
    
    let activeLayers: [HierarchyInspector.Layer]
    
    let expiryDate: Date = Date().addingTimeInterval(Self.cacheExpirationTimeInSeconds)
    
    #warning("consider keeping weak reference to views, or wrapper with metadata")
    //let filteredViews: [UIView] // TODO: would create strong reference, consider workaround wrapper
}
