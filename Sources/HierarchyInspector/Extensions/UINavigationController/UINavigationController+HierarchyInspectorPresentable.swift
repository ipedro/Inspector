//
//  UINavigationController+HierarchyInspectableProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectorPresentable

extension UINavigationController: HierarchyInspectorPresentable {
    public var hierarchyInspectorManager: HierarchyInspector.Manager {
        guard
            let existingManager = Self.currentHierarchyInspectorManager,
            existingManager.hostViewController === self
        else {
            
            let newManager = HierarchyInspector.Manager(host: self).then {
                $0.shouldCacheViewHierarchySnapshot = false
            }
            
            Self.currentHierarchyInspectorManager = newManager
            
            return newManager
        }
        
        return existingManager
    }
    
    public var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        hierarchyInspectableTopViewController?.hierarchyInspectorLayers ?? []
    }
    
    public var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme {
        hierarchyInspectableTopViewController?.hierarchyInspectorColorScheme ?? .default
    }
}

private extension UINavigationController {
    static var currentHierarchyInspectorManager: HierarchyInspector.Manager? {
        didSet {
            guard let previousManager = oldValue else {
                return
            }

            previousManager.removeAllLayers()
        }
    }
    
    var hierarchyInspectableTopViewController: HierarchyInspectableProtocol? {
        topViewController as? HierarchyInspectableProtocol
    }
}
