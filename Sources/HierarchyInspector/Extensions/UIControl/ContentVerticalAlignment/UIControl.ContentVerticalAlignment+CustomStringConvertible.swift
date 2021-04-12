//
//  UIControl.ContentVerticalAlignment+CustomImageConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIControl.ContentVerticalAlignment: CustomImageConvertible {
    var image: UIImage? {
        switch self {
        case .center:
            return IconKit.imageOfVerticalAlignmentCenter()
            
        case .top:
            return IconKit.imageOfVerticalAlignmentTop()
            
        case .bottom:
            return IconKit.imageOfVerticalAlignmentBottom()
            
        case .fill:
            return IconKit.imageOfVerticalAlignmentFill()
            
        @unknown default:
            return nil
        }
    }
}
