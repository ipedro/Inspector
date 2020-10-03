//
//  UITabBarController+HierarchyInspectableProtocol.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectorPresentable

extension UITabBarController: HierarchyInspectorPresentable {
    
    private var hierarchyInspectableSelectedViewController: HierarchyInspectableProtocol? {
        selectedViewController as? HierarchyInspectableProtocol
    }
    
    // TODO: code smell. split into other protocol to remove empty assessors
    public var hierarchyInspectorSnapshot: HierarchyInspector.ViewHierarchySnapshot? {
        get {
            nil
        }
        set {}
    }
    
    public var hierarchyInspectorViews: [HierarchyInspector.Layer: [HierarchyInspectorView]] {
        get {
            hierarchyInspectableSelectedViewController?.hierarchyInspectorViews ?? [:]
        }
        set {
            hierarchyInspectableSelectedViewController?.hierarchyInspectorViews = newValue
        }
    }
    
    public var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        hierarchyInspectableSelectedViewController?.hierarchyInspectorLayers ?? []
    }
    
    public var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme {
        hierarchyInspectableSelectedViewController?.hierarchyInspectorColorScheme ?? .default
    }
}
