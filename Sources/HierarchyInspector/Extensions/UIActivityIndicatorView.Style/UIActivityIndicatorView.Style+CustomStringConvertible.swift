//
//   UIActivityIndicatorView.Style+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

extension UIActivityIndicatorView.Style: CustomStringConvertible {
    
    #if swift(>=5.0)
    public var description: String {
        switch self {
        case .medium:
            return "Medium"
        
        case .large:
            return "Large"
        
        case .whiteLarge:
            return "White Large (deprecated)"
        
        case .white:
            return "White (deprecated)"
        
        case .gray:
            return "Gray (deprecated)"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    #else
    public var description: String {
        switch self {
        case .whiteLarge:
            return "White Large"
        
        case .white:
            return "White"
        
        case .gray:
            return "Gray"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    #endif
    
}
