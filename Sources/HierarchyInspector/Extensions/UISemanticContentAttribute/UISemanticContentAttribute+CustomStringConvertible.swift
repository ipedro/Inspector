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
            return "unspecified"
            
        case .playback:
            return "playback"
            
        case .spatial:
            return "spatial"
            
        case .forceLeftToRight:
            return "force left to right"
            
        case .forceRightToLeft:
            return "force right to left"
            
        @unknown default:
            return String(describing: self)
        }
    }
}
