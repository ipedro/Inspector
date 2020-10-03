//
//  HierarchyInspectableProtocol+LayerManagerProtocol.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - LayerManagerProtocol

extension HierarchyLayerManagerProtocol where Self: HierarchyInspectableProtocol {
    
    // MARK: - Install
    
    public func installLayer(_ layer: HierarchyInspector.Layer, in viewHierarchy: [UIView]) {
        let filteredViewHierarchy = layer.filter(viewHierarchy: self.view.inspectableViewHierarchy)
        
        performAsyncOperation {
            self.create(layer: layer, filteredViewHierarchy: filteredViewHierarchy)
        }
    }
    
    public func installAllLayers(in viewHierarchy: [UIView]) {
        performAsyncOperation {
            self.populatedHierarchyInspectorLayers.forEach { layer in
                let filteredViewHierarchy = layer.filter(viewHierarchy: self.view.inspectableViewHierarchy)
                
                self.create(layer: layer, filteredViewHierarchy: filteredViewHierarchy)
            }
        }
    }
    
    // MARK: - Remove
    
    public func removeAllLayers() {
        performAsyncOperation {
            for layer in self.hierarchyInspectorViews.keys {
                self.destroy(layer: layer)
            }
        }
    }

    public func removeLayer(_ layer: HierarchyInspector.Layer) {
        performAsyncOperation {
            self.destroy(layer: layer)
        }
    }
    
    // MARK: - Internal Layer Management
    
    func destroy(layer: HierarchyInspector.Layer) {
        hierarchyInspectorViews[layer]?.forEach { $0.removeFromSuperview() }
        
        hierarchyInspectorViews.removeValue(forKey: layer)
        
        if
            hierarchyInspectorViews.keys.count == 1,
            hierarchyInspectorViews.keys.contains(.wireframes) {
            removeLayer(.wireframes)
        }
    }
    
    func create(layer: HierarchyInspector.Layer, filteredViewHierarchy: [UIView]) {
        guard hierarchyInspectorViews[layer] == nil else {
            return
        }
        
        hierarchyInspectorViews[layer] = []
        
        if layer != .wireframes, hierarchyInspectorViews.keys.contains(.wireframes) == false {
            create(layer: .wireframes, filteredViewHierarchy: view.inspectableViewHierarchy)
        }
        
        guard filteredViewHierarchy.isEmpty == false else {
            let inspectorView = EmptyView(frame: view.frame, name: layer.emptyText)

            insert(inspectorView, for: layer, in: view, onTop: true)
            return
        }
        
        guard layer.showLabels else {
            filteredViewHierarchy.forEach { element in
                let inspectorView = WireframeView(frame: element.bounds)
                
                insert(inspectorView, for: layer, in: element, onTop: false)
            }
            return
        }
        
        filteredViewHierarchy.forEach { element in
            let inspectorView = HighlightView(
                frame: element.bounds,
                name: element === view ? element.className : element.elementName,
                colorScheme: hierarchyInspectorColorScheme
            )
            
            var canPresentOnTop: Bool {
                switch element {
                case view:
                    return false
                    
                case is UITextView:
                    return true
                    
                case is UIScrollView:
                    return false
                    
                default:
                    return true
                }
            }
            
            insert(inspectorView, for: layer, in: element, onTop: canPresentOnTop)
        }
    }
    
}
