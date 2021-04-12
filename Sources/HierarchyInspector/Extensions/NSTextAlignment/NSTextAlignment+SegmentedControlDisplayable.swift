//
//  NSTextAlignment+CustomImageConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 16.10.20.
//

import UIKit

extension NSTextAlignment: CustomImageConvertible {
    var image: UIImage? {
        switch self {
        case .left:
            return IconKit.imageOfTextAlignmentLeft()
            
        case .center:
            return IconKit.imageOfTextAlignmentCenter()
            
        case .right:
            return IconKit.imageOfTextAlignmentRight()
            
        case .justified:
            return IconKit.imageOfTextAlignmentJustified()
            
        case .natural:
            return IconKit.imageOfTextAlignmentNatural()
            
        @unknown default:
            return nil
        }
    }
}
