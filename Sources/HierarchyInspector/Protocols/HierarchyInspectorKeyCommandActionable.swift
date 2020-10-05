//
//  File.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectorKeyCommandPresentable: HierarchyInspectorPresentable {
    
    var presentHirearchyInspectorKeyCommandSelector: Selector? { get }
    
    var hierarchyInspectorKeyCommands: [UIKeyCommand] { get }
    
    var hierarchyInspectorKeyModifierFlags: UIKeyModifierFlags? { get }
}

// MARK: - KeyCommands

extension HierarchyInspectorKeyCommandPresentable {
    
    public var hierarchyInspectorKeyModifierFlags: UIKeyModifierFlags? {
        [.control]
    }
    
    public var hierarchyInspectorPresentationKeyModifierFlags: UIKeyModifierFlags? {
        guard var modifierFlags = hierarchyInspectorKeyModifierFlags else {
            return nil
        }
        
        modifierFlags.insert(HierarchyInspector.configuration.keyCommands.presentationModfifierFlags)
        
        return modifierFlags
    }
    
    public var hierarchyInspectorKeyCommands: [UIKeyCommand] {
        guard
            let modifierFlags = hierarchyInspectorKeyModifierFlags,
            let aSelector = presentHirearchyInspectorKeyCommandSelector
        else {
            return []
        }

//        let start = Date()
//
//        defer {
//            print("[Hierarchy Inspector] \(String(describing: classForCoder)): calculated KeyCommands in \(Date().timeIntervalSince(start)) seconds")
//        }

        var keyCommands = [UIKeyCommand]()

        var presentModifierFlags = HierarchyInspector.configuration.keyCommands.presentationModfifierFlags

        switch presentModifierFlags.insert(modifierFlags) {
        case (true, _):
            keyCommands.append(
                UIKeyCommand(
                    input: HierarchyInspector.configuration.keyCommands.presentationKeyCommand,
                    modifierFlags: presentModifierFlags,
                    action: aSelector,
                    discoverabilityTitle: Texts.openHierarchyInspector
                )
            )
        default:
            break
        }
        
        let availableCommandsInputRange = HierarchyInspector.configuration.keyCommands.availableCommandsInputRange
        
        var index = 0
        
        for actionGroup in hierarchyInspectorManager.availableActions {
            
            for action in actionGroup.actions {
                
                var input: String? {
                    switch action {
                    case .emptyLayer:
                        return nil
                        
                    case .toggleLayer:
                        return String(availableCommandsInputRange.lowerBound + index)
                        
                    case .showAllLayers, .hideVisibleLayers:
                        return HierarchyInspector.configuration.keyCommands.presentationKeyCommand
                    }
                }
                
                guard let keyInput = input else {
                    continue
                }
                
                
                keyCommands.append(
                    UIKeyCommand(
                        input: keyInput,
                        modifierFlags: modifierFlags,
                        action: aSelector,
                        discoverabilityTitle: action.title
                    )
                )
                
                if index == availableCommandsInputRange.upperBound - 1 {
                    break
                }
                
                index += 1
                
                
            }
            
        }
        
        return keyCommands
    }
    
    public func hierarchyInspectorHandleKeyCommand(_ sender: Any) {
        guard
            let keyCommand = sender as? UIKeyCommand,
            let keyModifierFlags = hierarchyInspectorKeyModifierFlags,
            let presentationKeyModifierFlags = hierarchyInspectorPresentationKeyModifierFlags
        else {
            return
        }
        
        switch (keyCommand.modifierFlags, keyCommand.input == HierarchyInspector.configuration.keyCommands.presentationKeyCommand) {
        case (presentationKeyModifierFlags, true):
            presentHierarchyInspector(animated: true)
            
        case (keyModifierFlags, true):
            switch hierarchyInspectorManager.isShowingLayers {
            case true:
                hierarchyInspectorManager.removeAllLayers()
                
            case false:
                hierarchyInspectorManager.installAllLayers()
            }
            
        default:
            guard let layer = layer(with: keyCommand) else {
                print("[Hierarchy Inspector] Layer not found for key command \(keyCommand)")
                return
            }
            
            switch hierarchyInspectorManager.isShowingLayer(layer) {
            case true:
                hierarchyInspectorManager.removeLayer(layer)
                
            case false:
                hierarchyInspectorManager.installLayer(layer)
            }
            
        }
    }
    
    private func layer(with keyCommand: UIKeyCommand) -> HierarchyInspector.Layer? {
        guard
            let input = keyCommand.input,
            let inputInteger = Int(input)
        else {
            print("[Hierarchy Inspector] Could not interpret input integer for key command \(keyCommand)")
            return nil
        }
        
        let inputRangeStart = HierarchyInspector.configuration.keyCommands.availableCommandsInputRange.lowerBound
        
        switch inputInteger - inputRangeStart {
        case hierarchyInspectorManager.populatedLayers.count:
            if
                keyCommand.discoverabilityTitle == HierarchyInspector.Layer.internalViews.selectedActionTitle ||
                keyCommand.discoverabilityTitle == HierarchyInspector.Layer.internalViews.unselectedActionTitle
            {
                return .internalViews
            }
            
        case let index:
            guard
                index < hierarchyInspectorManager.populatedLayers.count,
                HierarchyInspector.configuration.keyCommands.availableCommandsInputRange.contains(inputInteger)
            else {
                return nil
            }
            
            return hierarchyInspectorManager.populatedLayers[index]
        }
        
        return nil
    }
    
}
