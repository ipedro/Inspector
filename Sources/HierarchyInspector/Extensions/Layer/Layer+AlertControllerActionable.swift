//
//  UIAlertAction+Convenience.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - Actionable

extension HierarchyInspector.Layer: Actionable {
    
    var unselectedActionTitle: String {
        "[﹣] \(description)" // ☑️
    }
    
    var selectedActionTitle: String {
        "[✓] \(description)" // ✅
    }
    
}
