//
//  UISplitViewController+HierarchyInspectableProtocol.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectorPresentable

extension UISplitViewController: HierarchyInspectorPresentable {
    public var hierarchyInspectorViews: [HierarchyInspector.Layer : [HierarchyInspectorView]] {
        get {
            hierarchyInspectableViewControllers.first?.hierarchyInspectorViews ?? [:]
        }
        set {
            hierarchyInspectableViewControllers.first?.hierarchyInspectorViews = newValue
        }
    }
    
    public var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        var allLayers = Set<HierarchyInspector.Layer>()
        
        hierarchyInspectableViewControllers.forEach { viewController in
            viewController.hierarchyInspectorLayers.forEach { allLayers.insert($0) }
        }
        
        return Array(allLayers)
    }
    
    private var hierarchyInspectableViewControllers: [HierarchyInspectableProtocol] {
        viewControllers.compactMap { $0 as? HierarchyInspectableProtocol }
    }

    // TODO: code smell. split into other protocol to remove empty assessors
    public var hierarchyInspectorSnapshot: HierarchyInspector.ViewHierarchySnapshot? {
        get {
            nil
        }
        set {}
    }
}
