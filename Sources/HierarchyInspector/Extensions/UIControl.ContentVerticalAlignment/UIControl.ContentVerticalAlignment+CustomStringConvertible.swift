//
//  UIControl.ContentVerticalAlignment+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIControl.ContentVerticalAlignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .center:
            return "center"
            
        case .top:
            return "top"
            
        case .bottom:
            return "bottom"
            
        case .fill:
            return "fill"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
