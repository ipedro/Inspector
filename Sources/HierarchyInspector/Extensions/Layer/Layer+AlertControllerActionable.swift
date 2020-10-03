//
//  UIAlertAction+Convenience.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - AlertControllerActionable

extension HierarchyInspector.Layer: AlertControllerActionable {
    
    var unselectedAlertAction: String {
        "☑️ \(description)"
    }
    
    var selectedAlertAction: String {
        "✅ \(description)"
    }
    
}
