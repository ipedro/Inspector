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
        viewHierarchyLayersCoordinator.installLayer(layer)
    }

    public func installAllLayers() {
        viewHierarchyLayersCoordinator.installAllLayers()
    }

    // MARK: - Remove

    public func removeAllLayers() {
        viewHierarchyLayersCoordinator.removeAllLayers()
    }

    public func removeLayer(_ layer: ViewHierarchyLayer) {
        viewHierarchyLayersCoordinator.removeLayer(layer)
    }
    
}
