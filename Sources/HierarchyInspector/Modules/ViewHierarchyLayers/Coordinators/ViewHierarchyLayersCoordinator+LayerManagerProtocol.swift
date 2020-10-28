//
//  ViewHierarchyLayersCoordinator+LayerManagerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - LayerManagerProtocol

extension ViewHierarchyLayersCoordinator: LayerManagerProtocol {
    
    // MARK: - Install
    
    public func installLayer(_ layer: ViewHierarchyLayer) {
        guard let viewHierarchySnapshot = dataSource?.viewHierarchySnapshot else {
            return
        }
        
        asyncOperation(name: layer.selectedActionTitle) {
            self.create(layer: layer, for: viewHierarchySnapshot)
        }
    }
    
    public func installAllLayers() {
        guard let viewHierarchySnapshot = dataSource?.viewHierarchySnapshot else {
            return
        }
        
        asyncOperation(name: Texts.showAllLayers) {
            self.populatedLayers.forEach { layer in
                self.create(layer: layer, for: viewHierarchySnapshot)
            }
        }
    }
    
    // MARK: - Remove
    
    public func removeAllLayers() {
        asyncOperation(name: Texts.hideVisibleLayers) {
            self.destroyAllLayers()
        }
    }

    public func removeLayer(_ layer: ViewHierarchyLayer) {
        asyncOperation(name: layer.unselectedActionTitle) {
            self.destroy(layer: layer)
        }
    }
    
}
