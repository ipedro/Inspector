//
//  UIScrollView.IndicatorStyle+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIScrollView.IndicatorStyle: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .default:
            return "Default Style"
            
        case .black:
            return "Black"
            
        case .white:
            return "White"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    
}
