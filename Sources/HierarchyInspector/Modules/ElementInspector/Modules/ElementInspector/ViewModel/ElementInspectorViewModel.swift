//
//  ElementInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

enum ElementInspectorPanel: Int, CaseIterable {
    case propertyInspector, viewHierarchy
    
    var image: UIImage {
        switch self {
        case .propertyInspector:
            return IconKit.imageOfSliderHorizontal()
            
        case .viewHierarchy:
            return IconKit.imageOfListBulletIndent()
        }
    }
}

protocol ElementInspectorViewModelProtocol {
    var elementPanels: [ElementInspectorPanel] { get }
}

struct ElementInspectorViewModel: ElementInspectorViewModelProtocol {
    let reference: ViewHierarchyReference
    
    let elementPanels: [ElementInspectorPanel] = ElementInspectorPanel.allCases
    
}
