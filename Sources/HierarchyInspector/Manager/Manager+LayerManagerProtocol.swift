//
//  Manager+LayerManagerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

// MARK: - LayerManagerProtocol

extension HierarchyInspector.Manager: LayerManagerProtocol {
    
    // MARK: - Install
    
    public func installLayer(_ layer: ViewHierarchyLayer) {
        viewHierarchyInspectorCoordinator.installLayer(layer)
    }

    public func installAllLayers() {
        viewHierarchyInspectorCoordinator.installAllLayers()
    }

    // MARK: - Remove

    public func removeAllLayers() {
        viewHierarchyInspectorCoordinator.removeAllLayers()
    }

    public func removeLayer(_ layer: ViewHierarchyLayer) {
        viewHierarchyInspectorCoordinator.removeLayer(layer)
    }
    
}
