//
//  Manager+HierarchyLayerManagerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - LayerManagerProtocol

extension HierarchyInspector.Manager: HierarchyLayerManagerProtocol {
    
    // MARK: - Install
    
    public func installLayer(_ layer: HierarchyInspector.Layer) {
        let filteredViewHierarchy = layer.filter(viewHierarchy: inspectableViewHierarchy)
        
        async(operation: "Adding \(layer.name)") {
            self.create(layer: layer, filteredViewHierarchy: filteredViewHierarchy)
        }
    }
    
    public func installAllLayers() {
        async(operation: Texts.showAllLayers) {
            let inspectableViewHierarchy = self.inspectableViewHierarchy
            
            self.populatedLayers.forEach { layer in
                let filteredViewHierarchy = layer.filter(viewHierarchy: inspectableViewHierarchy)
                
                self.create(layer: layer, filteredViewHierarchy: filteredViewHierarchy)
            }
        }
    }
    
    // MARK: - Remove
    
    public func removeAllLayers() {
        async(operation: Texts.hideVisibleLayers) {
            for layer in self.inspectorViewsForLayers.keys {
                self.destroy(layer: layer)
            }
        }
    }

    public func removeLayer(_ layer: HierarchyInspector.Layer) {
        async(operation: "Hiding \(layer.name)") {
            self.destroy(layer: layer)
        }
    }
    
}
