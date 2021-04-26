//  Copyright (c) 2021 Pedro Almeida
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
    
    public var keyCommands: [UIKeyCommand] {
        hierarchyInspectorKeyCommands(selector: #selector(UIViewController.hierarchyInspectorKeyCommandHandler(_:)))
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
