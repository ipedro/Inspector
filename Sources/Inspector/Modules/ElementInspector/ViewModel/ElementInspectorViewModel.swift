//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

protocol ElementInspectorViewModelProtocol {
    var reference: ViewHierarchyReference { get }
    
    var availablePanels: [ElementInspectorPanel] { get }
    
    var selectedPanel: ElementInspectorPanel? { get }
    
    var selectedPanelSegmentIndex: Int { get }
    
    var showDismissBarButton: Bool { get }
}

final class ElementInspectorViewModel: ElementInspectorViewModelProtocol {
    let reference: ViewHierarchyReference
    
    let showDismissBarButton: Bool
    
    let inspectableElements: [InspectorElementLibraryProtocol]
    
    var selectedPanel: ElementInspectorPanel?
    
    var selectedPanelSegmentIndex: Int {
        guard
            let selectedPanel = selectedPanel,
            let selectedIndex = availablePanels.firstIndex(of: selectedPanel)
        else {
            return UISegmentedControl.noSegment
        }
        
        return selectedIndex
    }
    
    init(
        reference: ViewHierarchyReference,
        showDismissBarButton: Bool,
        selectedPanel: ElementInspectorPanel?,
        inspectableElements: [InspectorElementLibraryProtocol]
    ) {
        self.reference = reference
        self.showDismissBarButton = showDismissBarButton
        self.inspectableElements = inspectableElements
        
        if let selectedPanel = selectedPanel, availablePanels.contains(selectedPanel) {
            self.selectedPanel = selectedPanel
        }
        else {
            self.selectedPanel = availablePanels.first
        }
    }
    
    private(set) lazy var availablePanels: [ElementInspectorPanel] = ElementInspectorPanel.allCases.compactMap { panel in
        switch panel {
        case .viewHierarchyInspector:
            return reference.isContainer ? panel : nil
        case .autoLayoutInspector:
            return reference.constraintReferences.isEmpty ? nil : panel
        case .attributesInspector:
            return panel
        }
    }
}
