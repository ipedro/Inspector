//
//  UITextAutocorrectionType+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextAutocorrectionType: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .default:
            return "Default"
            
        case .no:
            return "No"
            
        case .yes:
            return "Yes"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    
}
