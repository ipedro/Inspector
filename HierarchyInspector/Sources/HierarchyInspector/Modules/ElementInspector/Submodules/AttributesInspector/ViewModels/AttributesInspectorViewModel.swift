//
//  AttributesInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol AttributesInspectorViewModelProtocol {
    var reference: ViewHierarchyReference { get}
    
    var sectionViewModels: [AttributesInspectorSectionViewModelProtocol] { get }
    
    var isHighlightingViews: Bool { get }
    
    var isLiveUpdating: Bool { get set }
}

final class AttributesInspectorViewModel: AttributesInspectorViewModelProtocol {
    var isHighlightingViews: Bool {
        reference.isHidingHighlightViews == false
    }
    
    var isLiveUpdating: Bool
    
    let reference: ViewHierarchyReference
    
    private(set) lazy var sectionViewModels: [AttributesInspectorSectionViewModelProtocol] = {
        guard let referenceView = reference.view else {
            return []
        }
        
        return AttributesInspectorSection.allCases(matching: referenceView).compactMap {
            $0.viewModel(with: referenceView)
        }
    }()
    
    init(reference: ViewHierarchyReference) {
        self.reference = reference
        self.isLiveUpdating = true
    }
}
