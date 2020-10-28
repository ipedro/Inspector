//
//  ElementInspectorPanel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 28.10.20.
//

import UIKit

enum ElementInspectorPanel: Int, CaseIterable {
    case attributesInspector
    case sizeInspector
    case viewHierarchyInspector
    
    var image: UIImage {
        switch self {
        case .attributesInspector:
            return IconKit.imageOfSliderHorizontal()
            
        case .viewHierarchyInspector:
            return IconKit.imageOfListBulletIndent()
            
        case .sizeInspector:
            return IconKit.imageOfSetSquareFill()
        }
    }
}
