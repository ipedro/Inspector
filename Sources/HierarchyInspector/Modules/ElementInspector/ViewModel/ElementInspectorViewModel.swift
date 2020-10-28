//
//  ElementInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

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
    
    private(set) lazy var elementPanels: [ElementInspectorPanel] = ElementInspectorPanel.allCases.compactMap {
        switch $0 {

        case .attributesInspector:
            return $0
            
        case .viewHierarchyInspector:
            return reference.isContainer ? $0 : nil
            
        case .sizeInspector:
            return $0
            
        }
    }
    
}
