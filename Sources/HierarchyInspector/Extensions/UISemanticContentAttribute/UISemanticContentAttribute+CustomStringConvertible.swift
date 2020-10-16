//
//  UISemanticContentAttribute+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UISemanticContentAttribute: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unspecified:
            return "Unspecified"
            
        case .playback:
            return "Playback"
            
        case .spatial:
            return "Spatial"
            
        case .forceLeftToRight:
            return "Force Left To Right"
            
        case .forceRightToLeft:
            return "Force right To Left"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
