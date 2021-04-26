//
//  Manager+KeyCommandHandlerProtocol.swift
//  
//
//  Created by Pedro on 26.04.21.
//

import UIKit

extension HierarchyInspector.Manager: KeyCommandHandlerProtocol {
    
    @objc public func hierarchyInspectorKeyCommandHandler(_ sender: Any) {
        guard let keyCommand = sender as? UIKeyCommand else {
            return
        }
        
        let flattenedActions = availableActionsForKeyCommand.flatMap { $0.actions }
        
        for action in flattenedActions where action.title == keyCommand.discoverabilityTitle {
            action.closure?()
            return
        }
    }
    
}
