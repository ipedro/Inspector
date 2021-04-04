//
//  File.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectorKeyCommandPresentable: HierarchyInspectorPresentable {
    
    var hirearchyInspectorKeyCommandsSelector: Selector? { get }
    
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
            let aSelector = hirearchyInspectorKeyCommandsSelector
        else {
            return []
        }
        
        var keyCommands = [UIKeyCommand]()
        
        let keyCommandsInputRange = HierarchyInspector.configuration.keyCommands.keyCommandsInputRange
        
        var index = 0
        
        for actionGroup in hierarchyInspectorManager.availableActionsForKeyCommand {
            
            for action in actionGroup.actions {
                
                var input: String? {
                    switch action {
                    case .emptyLayer:
                        return nil
                        
                    case .showAllLayers, .hideVisibleLayers:
                        return HierarchyInspector.configuration.keyCommands.openHierarchyInspectorInput
                        
                    default:
                        return String(keyCommandsInputRange.lowerBound + index)
                    }
                }
                
                guard let keyInput = input else {
                    continue
                }
                
                var actionModifierFlags: UIKeyModifierFlags {
                    guard var actionFlags = action.modifierFlags else {
                        return modifierFlags
                    }
                    
                    actionFlags.insert(modifierFlags)
                    
                    return actionFlags
                }
                
                keyCommands.append(
                    UIKeyCommand(
                        input: keyInput,
                        modifierFlags: actionModifierFlags,
                        action: aSelector,
                        discoverabilityTitle: action.title
                    )
                )
                
                if index == keyCommandsInputRange.upperBound - 1 {
                    break
                }
                
                index += 1
            }
            
        }
        
        keyCommands.sort { lhs, rhs -> Bool in
            guard
                let lhsInput = lhs.input,
                let rhsInput = rhs.input
            else {
                return true
            }
            
            return lhsInput < rhsInput
        }
        
        return keyCommands
    }
    
    /// Interprets key commands into HierarchyInspector actions.
    /// - Parameter sender: (Any) If sender is not of `UIKeyCommand` type methods does nothing.
    public func hierarchyInspectorKeyCommandHandler(_ sender: Any) {
        guard let keyCommand = sender as? UIKeyCommand else {
            return
        }
        
        let flattenedActions = hierarchyInspectorManager.availableActionsForKeyCommand.flatMap { $0.actions }
        
        for action in flattenedActions where action.title == keyCommand.discoverabilityTitle {
            
            switch action {
            
            case .emptyLayer:
                break
            
            case let .toggleLayer(_, closure),
                 let .showAllLayers(closure),
                 let .hideVisibleLayers(closure):
                closure()
                
            case let .openHierarchyInspector(fromViewController):
                fromViewController.presentHierarchyInspector(animated: true)
                
            case let .inspect(vc):
                vc.presentHierarchyInspector(animated: true)
                
            case let .inspectWindow(vc: vc):
                guard let window = vc.view.window else {
                    return
                }
                vc.hierarchyInspectorManager.presentElementInspector(for: ViewHierarchyReference(root: window), animated: true, from: nil)
            }
            
            return
        }
    
    }
    
}

extension HierarchyInspector.Manager {
    
    var availableActionsForKeyCommand: ActionGroups {
        var array = availableActions
        
        guard let hostViewController = hostViewController as? HierarchyInspectorPresentable else {
            return array
        }
        
        let openInspectorGroup = ActionGroup(
            title: nil,
            actions: [
                .openHierarchyInspector(from: hostViewController)
            ]
        )
        
        array.insert(openInspectorGroup, at: 0)
        
        return array
    }
    
}
