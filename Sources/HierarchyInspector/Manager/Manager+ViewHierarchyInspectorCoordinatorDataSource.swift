//
//  Manager+ViewHierarchyLayersCoordinatorDataSource.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

// MARK: - ViewHierarchyLayerCoordinatorDataSource

extension HierarchyInspector.Manager: ViewHierarchyLayersCoordinatorDataSource {
    var viewHierarchyWindow: UIWindow? {
        host.window?.hierarchyInspectorManager = self
        
        return host.window
    }
    
    var viewHierarchyColorScheme: ViewHierarchyColorScheme {
        host.hierarchyInspectorColorScheme
    }
    
}
