//
//  Manager+KeyCommandPresenterProtocol.swift
//  
//
//  Created by Pedro on 26.04.21.
//

import UIKit

// MARK: - HierarchyInspector Manager Extension

extension HierarchyInspector.Manager: KeyCommandPresenterProtocol {
    
    private var keyCommandSettings: HierarchyInspector.Configuration.KeyCommandSettings {
        HierarchyInspector.configuration.keyCommands
    }
    
    var availableActionsForKeyCommand: ActionGroups {
        var array = availableActionGroups
        
        let openInspectorGroup = ActionGroup(
            title: nil,
            actions: [
                .openHierarchyInspector(from: host)
            ]
        )
        
        array.insert(openInspectorGroup, at: 0)
        
        return array
    }
    
    var keyCommands: [UIKeyCommand] {
        hierarchyInspectorKeyCommands(selector: #selector(hierarchyInspectorKeyCommandHandler(_:)))
    }
    
    func hierarchyInspectorKeyCommands(selector aSelector: Selector) -> [UIKeyCommand] {
        var keyCommands = [UIKeyCommand]()
        
        var index = keyCommandSettings.layerToggleInputRange.lowerBound
        
        for actionGroup in availableActionsForKeyCommand {
            
            for action in actionGroup.actions {
                
                switch action {
                case .emptyLayer:
                    continue
                    
                case .openHierarchyInspector:
                    keyCommands.append(
                        UIKeyCommand(
                            keyCommandSettings.presentationOptions,
                            action: aSelector
                        )
                    )
                    
                case .showAllLayers,
                     .hideVisibleLayers:
                    keyCommands.append(
                        UIKeyCommand(
                            input: keyCommandSettings.allLayersToggleInput,
                            modifierFlags: keyCommandSettings.layerToggleModifierFlags,
                            action: aSelector,
                            discoverabilityTitle: action.title
                        )
                    )
                    
                case .hideLayer,
                     .showLayer:
                    
                    guard keyCommandSettings.layerToggleInputRange.contains(index) else {
                        break
                    }
                    
                    keyCommands.append(
                        UIKeyCommand(
                            input: String(index),
                            modifierFlags: keyCommandSettings.layerToggleModifierFlags,
                            action: aSelector,
                            discoverabilityTitle: action.title
                        )
                    )
                    
                    index += 1
                }
                
            }
            
        }
        
        return keyCommands.sortedByInputKey()
    }
    
}
