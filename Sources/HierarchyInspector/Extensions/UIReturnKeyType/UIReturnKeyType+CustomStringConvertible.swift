//
//  UIReturnKeyType+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIReturnKeyType: CustomStringConvertible {
    
    var description: String {
        switch self {
        
        case .default:
            return "Default"
            
        case .go:
            return "Go"
            
        case .google:
            return "Google"
            
        case .join:
            return "Join"
            
        case .next:
            return "Next"
            
        case .route:
            return "Route"
            
        case .search:
            return "Search"
            
        case .send:
            return "Send"
            
        case .yahoo:
            return "Yahoo"
            
        case .done:
            return "Done"
            
        case .emergencyCall:
            return "Emergency Call"
            
        case .continue:
            return "Continue"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    
}
