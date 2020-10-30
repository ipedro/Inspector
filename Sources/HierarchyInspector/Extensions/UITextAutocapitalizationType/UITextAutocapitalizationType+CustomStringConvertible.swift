//
//  UITextAutocapitalizationType+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextAutocapitalizationType: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        
        case .none:
            return "None"
            
        case .words:
            return "Words"
            
        case .sentences:
            return "Sentences"
            
        case .allCharacters:
            return "All Characters"
            
        @unknown default:
            return "\(self) (unsupported)"
            
        }
    }
    
}
