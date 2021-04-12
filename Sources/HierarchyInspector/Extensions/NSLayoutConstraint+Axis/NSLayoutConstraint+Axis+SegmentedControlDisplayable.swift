//
//  NSLayoutConstraint.Axis+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension NSLayoutConstraint.Axis: CustomStringConvertible {
    var description: String {
        switch self {
        case .horizontal:
            return "Horizontal"
            
        case .vertical:
            return "Vertical"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
