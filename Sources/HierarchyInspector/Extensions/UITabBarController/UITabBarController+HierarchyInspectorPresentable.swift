//
//  UITabBarController+HierarchyInspectableProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectorPresentable

extension UITabBarController: HierarchyInspectorPresentable {
    public var hierarchyInspectorManager: HierarchyInspector.Manager {
        guard
            let existingManager = Self.currentHierarchyInspectorManager,
            existingManager.containerViewController === self
        else {
            
            let newManager = HierarchyInspector.Manager(host: self)
            Self.currentHierarchyInspectorManager = newManager
            
            return newManager
        }
        
        return existingManager
    }

    public var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        hierarchyInspectableSelectedViewController?.hierarchyInspectorLayers ?? []
    }
    
    public var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme {
        hierarchyInspectableSelectedViewController?.hierarchyInspectorColorScheme ?? .default
    }
}

private extension UITabBarController {
    static var currentHierarchyInspectorManager: HierarchyInspector.Manager? {
        didSet {
            guard let previousManager = oldValue else {
                return
            }
            
            previousManager.removeAllLayers()
        }
    }
    
    var hierarchyInspectableSelectedViewController: HierarchyInspectableProtocol? {
        selectedViewController as? HierarchyInspectableProtocol
    }
}

