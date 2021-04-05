//
//  ThumbnailBackgroundStyle.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 27.10.20.
//

import UIKit

enum ThumbnailBackgroundStyle: Int, Swift.CaseIterable {
    case light, medium, dark
    
    var color: UIColor {
        switch self {
        case .light:
            return UIColor(white: 0.80, alpha: 1)
            
        case .medium:
            return UIColor(white: 0.45, alpha: 1)
            
        case .dark:
            return UIColor(white: 0.10, alpha: 1)
        }
    }
    
    var contrastingColor: UIColor {
        switch self {
        case .light:
            return .black
            
        case .medium:
            return .white
            
        case .dark:
            return .lightGray
        }
    }
    
    var image: UIImage {
        switch self {
        case .light:
            return IconKit.imageOfAppearanceLight()
            
        case .medium:
            return IconKit.imageOfAppearanceMedium()
            
        case .dark:
            return IconKit.imageOfAppearanceDark()
        }
    }
}
