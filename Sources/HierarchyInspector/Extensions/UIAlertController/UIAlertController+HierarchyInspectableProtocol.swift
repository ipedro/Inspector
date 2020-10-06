//
//  UIAlertController+HierarchyInspectableProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectorPresentable

extension UIAlertController: HierarchyInspectorPresentable {
    public var hierarchyInspectorManager: HierarchyInspector.Manager {
        guard
            let existingManager = Self.sharedHierarchyInspectorManager,
            existingManager.hostViewController === self
        else {
            
            let newManager = HierarchyInspector.Manager(host: self).then {
                $0.shouldCacheViewHierarchySnapshot = false
            }
            
            Self.sharedHierarchyInspectorManager = newManager
            
            return newManager
        }
        
        return existingManager
    }

    public var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        [
            .staticTexts,
            .stackViews,
            .containerViews
        ]
    }
}

extension UIAlertController {
    static var sharedHierarchyInspectorManager: HierarchyInspector.Manager? {
        didSet {
            guard let previousManager = oldValue else {
                return
            }

            previousManager.invalidate()
        }
    }
}
