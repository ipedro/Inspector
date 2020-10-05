//
//  Manager+HierarchyLayerConstructor.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyLayerConstructor

extension HierarchyInspector.Manager: HierarchyLayerConstructor {
    
    func isShowingLayer(_ layer: HierarchyInspector.Layer) -> Bool {
        activeLayers.contains(layer)
    }
    
    // MARK: - Create
    
    @discardableResult
    func create(layer: HierarchyInspector.Layer, for viewHierarchySnapshot: ViewHierarchySnapshot) -> Bool {
        guard viewHierarchyReferences[layer] == nil else {
            return false
        }
        
        if layer != .wireframes, viewHierarchyReferences.keys.contains(.wireframes) == false {
            create(layer: .wireframes, for: viewHierarchySnapshot)
        }
        
        let filteredHirerarchy = layer.filter(snapshot: viewHierarchySnapshot)
        
        let viewHierarchyRefences = filteredHirerarchy.map { ViewHierarchyReference(view: $0) }
        
        viewHierarchyReferences.updateValue(viewHierarchyRefences, forKey: layer)
        
        return true
    }
    
    // MARK: - Destroy
    
    @discardableResult
    func destroyAllLayers() -> Bool {
        viewHierarchyReferences.removeAll()
        
        return true
    }
    
    @discardableResult
    func destroy(layer: HierarchyInspector.Layer) -> Bool {
        viewHierarchyReferences.removeValue(forKey: layer)
        
        if Array(viewHierarchyReferences.keys) == [.wireframes] {
            viewHierarchyReferences.removeValue(forKey: .wireframes)
        }
        
        return true
    }
    
}
