//
//  UIKeyboardAppearance+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIKeyboardAppearance: CustomStringConvertible {
    
    var description: String {
        switch self {
        
        case .default:
            return "Default"
            
        case .dark:
            return "Dark"
            
        case .light:
            return "Light"
            
        @unknown default:
            return "\(self) (unsupported)"
            
        }
    }
    
}
