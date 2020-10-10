//
//  UIView.ContentMode+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIView.ContentMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .scaleToFill:
            return "scale to fill"
            
        case .scaleAspectFit:
            return "scale aspect fit"
            
        case .scaleAspectFill:
            return "scale aspect fill"
            
        case .redraw:
            return "redraw"
            
        case .center:
            return "center"
            
        case .top:
            return "top"
            
        case .bottom:
            return "bottom"
            
        case .left:
            return "left"
            
        case .right:
            return "right"
            
        case .topLeft:
            return "top left"
            
        case .topRight:
            return "top right"
            
        case .bottomLeft:
            return "bottom left"
            
        case .bottomRight:
            return "bottom right"
            
        @unknown default:
            return "unknown"
        }
    }
}
