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
        inspectorViewsForLayers[layer]?.isEmpty == false
    }
    
    // MARK: - Create
    
    @discardableResult
    func create(layer: HierarchyInspector.Layer, filteredViewHierarchy: [UIView]) -> Bool {
        guard
            let hostViewController = hostViewController,
            inspectorViewsForLayers[layer] == nil
        else {
            return false
        }
        
        inspectorViewsForLayers[layer] = []
        
        if layer != .wireframes, inspectorViewsForLayers.keys.contains(.wireframes) == false {
            create(layer: .wireframes, filteredViewHierarchy: hostViewController.view.inspectableViewHierarchy)
        }
        
        guard filteredViewHierarchy.isEmpty == false else {
            let inspectorView = EmptyView(frame: hostViewController.view.frame, name: layer.emptyText)

            insert(inspectorView, for: layer, in: hostViewController.view, onTop: true)
            return true
        }
        
        guard layer.showLabels else {
            filteredViewHierarchy.forEach { element in
                let inspectorView = WireframeView(frame: element.bounds)
                
                insert(inspectorView, for: layer, in: element, onTop: false)
            }
            return true
        }
        
        filteredViewHierarchy.forEach { element in
            let inspectorView = HighlightView(
                frame: element.bounds,
                name: element === hostViewController.view ? element.className : element.elementName,
                colorScheme: hostViewController.hierarchyInspectorColorScheme
            )
            
            var canPresentOnTop: Bool {
                switch element {
                case hostViewController.view:
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
        
        return true
    }
    
    // MARK: - Destroy
    
    @discardableResult
    func destroyAllLayers() -> Bool {
        inspectorViewsForLayers.removeAll()
        
        return true
    }
    
    @discardableResult
    func destroy(layer: HierarchyInspector.Layer) -> Bool {
        inspectorViewsForLayers.removeValue(forKey: layer)
        
        if Array(inspectorViewsForLayers.keys) == [.wireframes] {
            inspectorViewsForLayers.removeValue(forKey: .wireframes)
        }
        
        return true
    }
    
}

private extension HierarchyInspector.Manager {
    
    func insert(_ inspectorView: View, for layer: HierarchyInspector.Layer, in element: HierarchyInspectableView, onTop: Bool) {
        element.installView(inspectorView, position: .top) // TODO: make not set margins
        
        var views = inspectorViewsForLayers[layer] ?? []
        
        views.append(inspectorView)
        
        inspectorViewsForLayers[layer] = views
    }
    
}
