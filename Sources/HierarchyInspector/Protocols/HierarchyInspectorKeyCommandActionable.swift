//
//  File.swift
//  
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectorKeyCommandPresentable: HierarchyInspectorPresentable {
    
    var toggleHirearchyInspectorLayerKeyCommandAction: Selector? { get }
    
    var presentHirearchyInspectorKeyCommandAction: Selector? { get }
    
    var hierarchyInspectorKeyCommands: [UIKeyCommand] { get }
    
    var hierarchyInspectorKeyModifierFlags: UIKeyModifierFlags? { get }
}

// MARK: - KeyCommands

extension HierarchyInspectorKeyCommandPresentable {
    
    public var hierarchyInspectorKeyModifierFlags: UIKeyModifierFlags? {
        [.control]
    }
    
    public var hierarchyInspectorKeyCommands: [UIKeyCommand] {
        guard let modifierFlags = hierarchyInspectorKeyModifierFlags else {
            return []
        }
        
        let start = Date()
        
        defer {
            print("[Hierarchy Inspector] \(String(describing: classForCoder)): calculated KeyCommands in \(Date().timeIntervalSince(start)) seconds")
        }
        
        var keyCommands = [UIKeyCommand]()
        
        if let showInspectorAction = presentHirearchyInspectorKeyCommandAction {
            var presentModifierFlags = HierarchyInspector.configuration.keyCommands.hierarchyInspector.presentationModfifierFlags
            
            switch presentModifierFlags.insert(modifierFlags) {
            case (true, _):
                keyCommands.append(
                    UIKeyCommand(
                        input: HierarchyInspector.configuration.keyCommands.hierarchyInspector.presentationInput,
                        modifierFlags: presentModifierFlags,
                        action: showInspectorAction,
                        discoverabilityTitle: Texts.openHierarchyInspector
                    )
                )
            default:
                break
            }
        }
        
        guard let toggleLayerAction = toggleHirearchyInspectorLayerKeyCommandAction else {
            return keyCommands
        }
        
        let toggleLayersSlots = HierarchyInspector.configuration.keyCommands.layers.tooggleKeyCommandsInputRange
        
        let availableLayers = populatedHierarchyInspectorLayers
        
        availableLayers.enumerated().prefix(toggleLayersSlots.count).forEach { index, layer in
            let isShowing = self.isShowing(layer: layer)
            let title = isShowing ? layer.selectedKeyCommand : layer.unselectedKeyCommand
            
            keyCommands.append(
                UIKeyCommand(
                    input: String(toggleLayersSlots.lowerBound + index),
                    modifierFlags: modifierFlags,
                    action: toggleLayerAction,
                    discoverabilityTitle: title
                )
            )
        }
        
        var containsAllLayers: Bool {
            for layer in availableLayers where hierarchyInspectorViews.keys.contains(layer) == false {
                return false
            }
            
            return true
        }
        
        let toggleAllTitle: String
        
        if containsAllLayers == false {
            toggleAllTitle  = Texts.showAllLayers
        }
        else if hierarchyInspectorViews.keys.count > 1 {
            toggleAllTitle  = Texts.hideAllLayers
        }
        else {
            return keyCommands
        }
        
        keyCommands.append(
            UIKeyCommand(
                input: HierarchyInspector.configuration.keyCommands.layers.tooggleAllKeyCommandsInput,
                modifierFlags: modifierFlags,
                action: toggleLayerAction,
                discoverabilityTitle: toggleAllTitle
            )
        )
        
        return keyCommands
    }
    
    public func hierarchyInspectorHandleKeyCommand(_ sender: Any) {
        guard
            let keyCommand = sender as? UIKeyCommand,
            keyCommand.modifierFlags == hierarchyInspectorKeyModifierFlags,
            let layer = populatedHierarchyInspectorLayers.layer(for: keyCommand)
        else {
            return
        }
        
        let isShowing = self.isShowing(layer: layer)
        
        switch keyCommand.input {
        case HierarchyInspector.configuration.keyCommands.layers.tooggleAllKeyCommandsInput:
            isShowing ? removeAllLayers() : installAllLayers(in: view.inspectableViewHierarchy)
            
        default:
            isShowing ? removeLayer(layer) : installLayer(layer, in: view.inspectableViewHierarchy)
        }
    }
    
}
