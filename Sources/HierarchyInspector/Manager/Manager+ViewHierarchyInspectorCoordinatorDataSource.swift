//
//  Manager+ViewHierarchyInspectorCoordinatorDataSource.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

// MARK: - ViewHierarchyLayerCoordinatorDataSource

extension HierarchyInspector.Manager: ViewHierarchyInspectorCoordinatorDataSource {
    
    var viewHierarchyWindow: UIWindow? {
        hostViewController?.view.window
    }
    
    var viewHierarchyColorScheme: ViewHierarchyColorScheme {
        hostViewController?.hierarchyInspectorColorScheme ?? .default
    }
    
}
