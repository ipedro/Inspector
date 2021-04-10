//
//  UITextField.BorderStyle+SegmentedControlDisplayable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextField.BorderStyle: SegmentedControlDisplayable {
    var displayItem: Any {
        switch self {
        
        case .none:
            return IconKit.imageOfBorderStyleNone()
            
        case .line:
            return IconKit.imageOfBorderStyleLine()
            
        case .bezel:
            return IconKit.imageOfBorderStyleBezel()
            
        case .roundedRect:
            return IconKit.imageOfBorderStyleRoundedRect()
            
        @unknown default:
            return UIImage()
            
        }
    }
}
