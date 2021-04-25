//
//  UIWindow+HierarchyInspectorManager.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 25.04.21.
//

import UIKit
import ObjectAssociation

public extension UIWindow {
    
    private static let managers = ObjectAssociation<HierarchyInspector.Manager>()
    
    var hierarchyInspectorManager: HierarchyInspector.Manager? {
        get { Self.managers[self] }
        set { Self.managers[self] = newValue }
    }
    
    func presentHierarchyInspector(animated: Bool) {
        hierarchyInspectorManager?.present(animated: animated)
    }
}
