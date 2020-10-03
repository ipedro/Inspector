//
//  ViewHierarchySnapshot.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import Foundation

extension HierarchyInspector {
    
    struct ViewHierarchySnapshot {
        
        // MARK: - Properties
        
        static var cacheExpirationTimeInSeconds: Double = 60
        
        let populatedHirerchyLayers: [Layer]
        
        let expiryDate: Date = Date().addingTimeInterval(Self.cacheExpirationTimeInSeconds)
        
        //let filteredViews: [UIView] // TODO: would create strong reference, consider workaround wrapper
    }
    
}
