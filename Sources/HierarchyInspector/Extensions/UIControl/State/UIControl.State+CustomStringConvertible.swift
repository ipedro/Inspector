//
//  UIControl.State+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIControl.State: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .normal:
            return "Default"
            
        case .highlighted:
            return "Highlighted"
            
        case .disabled:
            return "Disabled"
            
        case .selected:
            return "Selected"
            
        case .focused:
            return "Focused"
            
        case .application:
            return "Application"
            
        case .reserved:
            return "Reserved"
            
        default:
            return "Unknown"
        }
    }
    
}
