//
//  UITextField.ViewMode+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextField.ViewMode: CustomStringConvertible {
    
    var description: String {
        switch self {
        
        case .never:
            return "Never"
            
        case .whileEditing:
            return "While Editing"
            
        case .unlessEditing:
            return "Unless Editing"
            
        case .always:
            return "Always"
            
        @unknown default:
            return "Unknown"
            
        }
    }
    
}
