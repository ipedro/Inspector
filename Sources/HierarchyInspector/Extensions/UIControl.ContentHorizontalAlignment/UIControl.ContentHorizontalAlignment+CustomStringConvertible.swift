//
//  UIControl.ContentHorizontalAlignment+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIControl.ContentHorizontalAlignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .leading:
            return "|L]"
            
        case .left:
            return "| ]"
            
        case .center:
            return "[|]"
            
        case .right:
            return "[ |"
            
        case .trailing:
            return "[T|"
            
        case .fill:
            return "[⟷]"
            
        @unknown default:
            return String(describing: self)
        }
    }
}
