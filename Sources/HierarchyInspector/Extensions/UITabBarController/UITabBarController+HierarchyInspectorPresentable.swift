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

    public var hierarchyInspectorLayers: [ViewHierarchyLayer] {
        hierarchyInspectableSelectedViewController?.hierarchyInspectorLayers ?? []
    }
    
    public var hierarchyInspectorColorScheme: ViewHierarchyColorScheme {
        hierarchyInspectableSelectedViewController?.hierarchyInspectorColorScheme ?? .default
    }
}

private extension UITabBarController {
    static var currentHierarchyInspectorManager: HierarchyInspector.Manager? {
        didSet {
            guard let previousManager = oldValue else {
                return
            }
            
            previousManager.invalidate()
        }
    }
    
    var hierarchyInspectableSelectedViewController: HierarchyInspectableProtocol? {
        selectedViewController as? HierarchyInspectableProtocol
    }
}

