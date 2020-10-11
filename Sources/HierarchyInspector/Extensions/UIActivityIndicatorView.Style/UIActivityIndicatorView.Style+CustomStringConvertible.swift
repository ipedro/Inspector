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
            return "medium"
        
        case .large:
            return "large"
        
        case .whiteLarge:
            return "white large (deprecated)"
        
        case .white:
            return "white (deprecated)"
        
        case .gray:
            return "gray (deprecated)"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    #else
    public var description: String {
        switch self {
        case .whiteLarge:
            return "white large"
        
        case .white:
            return "white"
        
        case .gray:
            return "gray"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    #endif
    
}
