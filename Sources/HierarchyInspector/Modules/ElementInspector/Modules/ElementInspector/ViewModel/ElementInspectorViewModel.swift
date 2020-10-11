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
    var reference: ViewHierarchyReference { get }
    
    var elementPanels: [ElementInspectorPanel] { get }
    
    var showDismissBarButton: Bool { get }
}

final class ElementInspectorViewModel: ElementInspectorViewModelProtocol {
    let reference: ViewHierarchyReference
    
    let showDismissBarButton: Bool
    
    init(reference: ViewHierarchyReference, showDismissBarButton: Bool) {
        self.reference = reference
        self.showDismissBarButton = showDismissBarButton
    }
    
    private(set) lazy var elementPanels: [ElementInspectorPanel] = {
        var array: [ElementInspectorPanel] = [.propertyInspector]
        
        if reference.isContainer {
            array.append(.viewHierarchy)
        }
        
        return array
    }()
    
}
