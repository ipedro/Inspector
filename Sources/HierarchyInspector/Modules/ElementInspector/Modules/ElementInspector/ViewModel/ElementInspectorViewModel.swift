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
    
    var selectedPanel: ElementInspectorPanel? { get }
    
    var showDismissBarButton: Bool { get }
}

final class ElementInspectorViewModel: ElementInspectorViewModelProtocol {
    let reference: ViewHierarchyReference
    
    let showDismissBarButton: Bool
    
    var selectedPanel: ElementInspectorPanel?
    
    init(reference: ViewHierarchyReference, showDismissBarButton: Bool, selectedPanel: ElementInspectorPanel?) {
        self.reference = reference
        self.selectedPanel = selectedPanel
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
