//
//  UIView.ContentMode+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIView.ContentMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .scaleToFill:
            return "Scale To Fill"
            
        case .scaleAspectFit:
            return "Scale Aspect Fit"
            
        case .scaleAspectFill:
            return "Scale Aspect Fill"
            
        case .redraw:
            return "Redraw"
            
        case .center:
            return "Center"
            
        case .top:
            return "Top"
            
        case .bottom:
            return "Bottom"
            
        case .left:
            return "Left"
            
        case .right:
            return "Right"
            
        case .topLeft:
            return "Top Left"
            
        case .topRight:
            return "Top Right"
            
        case .bottomLeft:
            return "Bottom Left"
            
        case .bottomRight:
            return "Bottom Right"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
