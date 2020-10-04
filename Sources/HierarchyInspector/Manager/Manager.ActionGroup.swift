//
//  Manager.ActionGroup.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.10.20.
//

import UIKit

extension HierarchyInspector.Manager {
    
    struct ActionGroup {
        let title: String?
        
        var displayName: String {
            guard let title = title else {
                return "✻"
            }
            
            return "✻ \(title) ✻"
        }
        
        let actions: [Action]
    }
    
}

// MARK: - UIAlertAction Extension

extension HierarchyInspector.Manager.ActionGroup {
    
    var alertActions: [UIAlertAction] {
        var array = [UIAlertAction]()
        
        // group title
        array.append(
            UIAlertAction(title: displayName, style: .default, handler: nil).then { $0.isEnabled = false }
        )
        
        // group actions
        actions.forEach {
            guard let alertAction = $0.alertAction else {
                return
            }
            
            array.append(alertAction)
        }
        
        return array
    }
    
}
