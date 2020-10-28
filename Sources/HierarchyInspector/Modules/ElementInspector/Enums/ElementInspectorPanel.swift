//
//  ElementInspectorPanel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 28.10.20.
//

import UIKit

enum ElementInspectorPanel: Int, CaseIterable {
    case attributesInspector
    case viewHierarchyInspector
    
    var image: UIImage {
        switch self {
        case .attributesInspector:
            return IconKit.imageOfSliderHorizontal()
            
        case .viewHierarchyInspector:
            return IconKit.imageOfListBulletIndent()
        }
    }
}
