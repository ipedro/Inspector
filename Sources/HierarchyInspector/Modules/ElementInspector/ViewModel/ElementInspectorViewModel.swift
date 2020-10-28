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
    
    var selectedPanelSegmentIndex: Int { get }
    
    var showDismissBarButton: Bool { get }
}

final class ElementInspectorViewModel: ElementInspectorViewModelProtocol {
    let reference: ViewHierarchyReference
    
    let showDismissBarButton: Bool
    
    var selectedPanel: ElementInspectorPanel?
    
    var selectedPanelSegmentIndex: Int {
        guard
            let selectedPanel = selectedPanel,
            let selectedIndex = elementPanels.firstIndex(of: selectedPanel)
        else {
            return UISegmentedControl.noSegment
        }
        
        return selectedIndex
    }
    
    init(reference: ViewHierarchyReference, showDismissBarButton: Bool, selectedPanel: ElementInspectorPanel?) {
        self.reference = reference
        self.showDismissBarButton = showDismissBarButton
        
        if let selectedPanel = selectedPanel, elementPanels.contains(selectedPanel) {
            self.selectedPanel = selectedPanel
        }
        else {
            self.selectedPanel = elementPanels.first
        }
    }
    
    private(set) lazy var elementPanels: [ElementInspectorPanel] = {
        var array: [ElementInspectorPanel] = [.propertyInspector]
        
        if reference.isContainer {
            array.append(.viewHierarchy)
        }
        
        return array
    }()
    
}
