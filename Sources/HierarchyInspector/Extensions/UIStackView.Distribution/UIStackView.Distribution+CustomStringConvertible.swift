//
//  UIStackView.Distribution+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIStackView.Distribution: CustomStringConvertible {
    public var description: String {
        switch self {
        case .fill:
            return "fill"
            
        case .fillEqually:
            return "fill equally"
            
        case .fillProportionally:
            return "fill proportionally"
            
        case .equalSpacing:
            return "equal spacing"
            
        case .equalCentering:
            return "equal centering"
            
        @unknown default:
            return String(describing: self)
        }
    }
}
