//
//  Manager+Actions.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.10.20.
//

import Foundation

// MARK: - Actions

extension HierarchyInspector.Manager {
    
    var availableActions: [ActionGroup] {
        guard let viewHierarchySnapshot = self.viewHierarchySnapshot else {
            return []
        }
        
        var actionGroups = [ActionGroup]()
        
        // layer actions
        actionGroups.append(layerActions(for: viewHierarchySnapshot))
        
        // other actions
        actionGroups.append(otherActions(for: viewHierarchySnapshot))
        
        return actionGroups
    }
    
}

private extension HierarchyInspector.Manager {
    
    func layerActions(for snapshot: ViewHierarchySnapshot) -> ActionGroup {
        var actions = snapshot.availableLayers.map { layer in
            layerAction(layer, isEmpty: snapshot.populatedLayers.contains(layer) == false)
        }
        
        actions.append(layerAction(.internalViews, isEmpty: false))
        
        return ActionGroup(
            title: snapshot.availableLayers.isEmpty ? Texts.noLayers : Texts.layers(actions.count),
            actions: actions
        )
    }
    
    func layerAction(_ layer: HierarchyInspector.Layer, isEmpty: Bool) -> Action {
        if isEmpty {
            return .emptyLayer(layer.emptyActionTitle)
        }
        
        switch isShowingLayer(layer) {
        case true:
            return .toggleLayer(layer.selectedActionTitle) { [weak self] in
                self?.removeLayer(layer)
            }
            
        case false:
            return .toggleLayer(layer.unselectedActionTitle) { [weak self] in
                self?.installLayer(layer)
            }
        }
    }
    
    func otherActions(for snapshot: ViewHierarchySnapshot) -> ActionGroup {
        ActionGroup(
            title: nil,
            actions: {
                var array = [Action]()
                
                if activeLayers.count > .zero {
                    array.append(
                        .hideVisibleLayers { [weak self] in self?.removeAllLayers() }
                    )
                }
                
                if activeLayers.count < populatedLayers.count {
                    array.append(
                        .showAllLayers { [weak self] in self?.installAllLayers() }
                    )
                }
                
                if
                    let topMostContainer = hostViewController?.topMostContainerViewController as? HierarchyInspectorPresentable,
                    topMostContainer !== hostViewController
                    {
                    
                    array.append(.inspect(vc: topMostContainer))
                    
                }
                
                return array
            }()
        )
    }
}
