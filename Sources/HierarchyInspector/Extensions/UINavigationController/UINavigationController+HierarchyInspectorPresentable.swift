//
//  UINavigationController+HierarchyInspectableProtocol.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectorPresentable

extension UINavigationController: HierarchyInspectorPresentable {
    
    private var hierarchyInspectableTopViewController: HierarchyInspectableProtocol? {
        topViewController as? HierarchyInspectableProtocol
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
            hierarchyInspectableTopViewController?.hierarchyInspectorViews ?? [:]
        }
        set {
            hierarchyInspectableTopViewController?.hierarchyInspectorViews = newValue
        }
    }
    
    public var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        hierarchyInspectableTopViewController?.hierarchyInspectorLayers ?? []
    }
    
    public var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme {
        hierarchyInspectableTopViewController?.hierarchyInspectorColorScheme ?? .default
    }
}
