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
    
    func installLayer(_ layer: ViewHierarchyLayer) {
        guard let viewHierarchySnapshot = dataSource?.viewHierarchySnapshot else {
            return
        }
        
        asyncOperation(name: layer.title) {
            self.create(layer: layer, for: viewHierarchySnapshot)
        }
    }
    
    func installAllLayers() {
        guard let viewHierarchySnapshot = dataSource?.viewHierarchySnapshot else {
            return
        }
        
        asyncOperation(name: Texts.showAllLayers) {
            for layer in self.populatedLayers where layer.allowsSystemViews == false {
                self.create(layer: layer, for: viewHierarchySnapshot)
            }
        }
    }
    
    // MARK: - Remove
    
    func removeAllLayers() {
        guard isShowingLayers else {
            return
        }
        
        asyncOperation(name: Texts.hideVisibleLayers) {
            self.destroyAllLayers()
        }
    }

    func removeLayer(_ layer: ViewHierarchyLayer) {
        guard isShowingLayers else {
            return
        }
        
        asyncOperation(name: layer.title) {
            self.destroy(layer: layer)
        }
    }
    
}
