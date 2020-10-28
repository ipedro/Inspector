//
//  PropertyInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol PropertyInspectorViewModelProtocol {
    var reference: ViewHierarchyReference { get}
    
    var sectionViewModels: [PropertyInspectorSectionViewModelProtocol] { get }
    
    var isHighlightingViews: Bool { get }
    
    var isLiveUpdating: Bool { get set }
}

final class PropertyInspectorViewModel: PropertyInspectorViewModelProtocol {
    var isHighlightingViews: Bool {
        reference.isHidingHighlightViews == false
    }
    
    var isLiveUpdating: Bool
    
    let reference: ViewHierarchyReference
    
    private(set) lazy var sectionViewModels: [PropertyInspectorSectionViewModelProtocol] = {
        guard let referenceView = reference.view else {
            return []
        }
        
        return PropertyInspectorSection.allCases(matching: referenceView).compactMap {
            $0.viewModel(with: referenceView)
        }
    }()
    
    init(reference: ViewHierarchyReference) {
        self.reference = reference
        self.isLiveUpdating = true
    }
}
