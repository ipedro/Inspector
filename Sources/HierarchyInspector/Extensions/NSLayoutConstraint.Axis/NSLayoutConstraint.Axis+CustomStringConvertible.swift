//
//  NSLayoutConstraint.Axis+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension NSLayoutConstraint.Axis: CustomStringConvertible {
    public var description: String {
        switch self {
        case .horizontal:
            return "horizontal"
            
        case .vertical:
            return "vertical"
            
        @unknown default:
            return String(describing: self)
        }
    }
}
