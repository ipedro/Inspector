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
            return "Fill"
            
        case .leading:
            return "Leading"
            
        case .firstBaseline:
            return "First Baseline"
            
        case .center:
            return "Center"
            
        case .trailing:
            return "Trailing"
            
        case .lastBaseline:
            return "Last Baseline"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
