//
//  UIStackView.Distribution+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIStackView.Distribution: CustomStringConvertible {
    var description: String {
        switch self {
        case .fill:
            return "Fill"
            
        case .fillEqually:
            return "Fill Equally"
            
        case .fillProportionally:
            return "Fill Proportionally"
            
        case .equalSpacing:
            return "Equal Spacing"
            
        case .equalCentering:
            return "Equal Centering"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
}
