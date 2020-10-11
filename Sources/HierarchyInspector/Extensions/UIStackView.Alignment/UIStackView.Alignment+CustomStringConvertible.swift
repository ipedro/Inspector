//
//  UIStackView.Alignment+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIStackView.Alignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .fill:
            return "fill"
            
        case .leading:
            return "leading"
            
        case .firstBaseline:
            return "first baseline"
            
        case .center:
            return "center"
            
        case .trailing:
            return "trailing"
            
        case .lastBaseline:
            return "last baseline"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
