//
//  ViewHierarchyInspectorCoordinator+LayerConstructorProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - LayerConstructorProtocol

extension ViewHierarchyInspectorCoordinator: LayerConstructorProtocol {
    
    func isShowingLayer(_ layer: ViewHierarchyLayer) -> Bool {
        activeLayers.contains(layer)
    }
    
    // MARK: - Create
    
    @discardableResult
    func create(layer: ViewHierarchyLayer, for viewHierarchySnapshot: ViewHierarchySnapshot) -> Bool {
        guard visibleReferences[layer] == nil else {
            return false
        }
        
        if layer != .wireframes, visibleReferences.keys.contains(.wireframes) == false {
            create(layer: .wireframes, for: viewHierarchySnapshot)
        }
        
        let filteredHirerarchy = layer.filter(snapshot: viewHierarchySnapshot)
        
        let viewHierarchyRefences = filteredHirerarchy.map { ViewHierarchyReference(root: $0) }
        
        visibleReferences.updateValue(viewHierarchyRefences, forKey: layer)
        
        return true
    }
    
    // MARK: - Destroy
    
    @discardableResult
    func destroyAllLayers() -> Bool {
        visibleReferences.removeAll()
        
        return true
    }
    
    @discardableResult
    func destroy(layer: ViewHierarchyLayer) -> Bool {
        visibleReferences.removeValue(forKey: layer)
        
        if Array(visibleReferences.keys) == [.wireframes] {
            visibleReferences.removeValue(forKey: .wireframes)
        }
        
        return true
    }
    
}
