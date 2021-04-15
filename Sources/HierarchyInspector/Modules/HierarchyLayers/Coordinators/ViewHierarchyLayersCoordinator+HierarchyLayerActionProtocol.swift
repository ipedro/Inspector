//
//  ViewHierarchyLayersCoordinator+LayerActionProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

extension ViewHierarchyLayersCoordinator: LayerActionProtocol {
    
    func layerActions(for snapshot: ViewHierarchySnapshot) -> ActionGroup {
        let layerToggleInputRange = HierarchyInspector.configuration.keyCommands.layerToggleInputRange
        
        let maxCount = layerToggleInputRange.upperBound - layerToggleInputRange.lowerBound
        
        let actions = snapshot.availableLayers.map { layer in
            layerAction(layer, isEmpty: snapshot.populatedLayers.contains(layer) == false)
        }
        
        return ActionGroup(
            title: actions.isEmpty ? Texts.noLayers : Texts.viewLayers,
            actions: Array(actions.prefix(maxCount))
        )
    }
    
    func layerAction(_ layer: ViewHierarchyLayer, isEmpty: Bool) -> Action {
        if isEmpty {
            return .emptyLayer(layer.emptyActionTitle)
        }
        
        switch isShowingLayer(layer) {
        case true:
            return .showLayer(layer.title) { [weak self] in
                self?.removeLayer(layer)
            }
            
        case false:
            return .hideLayer(layer.title) { [weak self] in
                self?.installLayer(layer)
            }
        }
    }
    
    func toggleAllLayersActions(for snapshot: ViewHierarchySnapshot) -> ActionGroup {
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
                
                return array
            }()
        )
    }
}
