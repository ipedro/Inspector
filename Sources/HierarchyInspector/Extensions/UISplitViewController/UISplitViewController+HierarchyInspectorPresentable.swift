//
//  UISplitViewController+HierarchyInspectableProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectorPresentable

extension UISplitViewController: HierarchyInspectorPresentable {
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
    
    public var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme {
        for vc in hierarchyInspectableViewControllers {
            return vc.hierarchyInspectorColorScheme
        }
        
        return .default
    }
    
    public var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        var allLayers = Set<HierarchyInspector.Layer>()
        
        hierarchyInspectableViewControllers.forEach { viewController in
            viewController.hierarchyInspectorLayers.forEach { allLayers.insert($0) }
        }
        
        return Array(allLayers)
    }
}

private extension UISplitViewController {
    static var currentHierarchyInspectorManager: HierarchyInspector.Manager? {
        didSet {
            guard let previousManager = oldValue else {
                return
            }

            previousManager.removeAllLayers()
        }
    }
    
    var hierarchyInspectableViewControllers: [HierarchyInspectableProtocol] {
        viewControllers.compactMap { $0 as? HierarchyInspectableProtocol }
    }
}
