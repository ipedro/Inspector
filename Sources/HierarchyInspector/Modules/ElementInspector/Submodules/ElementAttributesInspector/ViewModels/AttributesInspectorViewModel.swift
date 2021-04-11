//
//  AttributesInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol AttributesInspectorViewModelProtocol: ElementViewHierarchyPanelViewModelProtocol {
    var sectionViewModels: [AttributesInspectorSectionViewModelProtocol] { get }
    
    var isHighlightingViews: Bool { get }
    
    var isLiveUpdating: Bool { get set }
}

final class AttributesInspectorViewModel {
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

// MARK: - AttributesInspectorViewModelProtocol

extension AttributesInspectorViewModel: AttributesInspectorViewModelProtocol {
    var parent: ElementViewHierarchyPanelViewModelProtocol? {
        get { nil }
        set { }
    }
    
    var thumbnailImage: UIImage? { reference.iconImage() }
    
    var title: String { reference.elementName }
    
    var titleFont: UIFont { ElementInspector.appearance.titleFont(forRelativeDepth: .zero) }
    
    var subtitle: String { reference.elementDescription }
    
    var isContainer: Bool { false }
    
    var isCollapsed: Bool {
        get { true }
        set { }
    }
    
    var isHidden: Bool { false }
    
    var accessoryType: UITableViewCell.AccessoryType { .none }
    
    var relativeDepth: Int { .zero }
}
