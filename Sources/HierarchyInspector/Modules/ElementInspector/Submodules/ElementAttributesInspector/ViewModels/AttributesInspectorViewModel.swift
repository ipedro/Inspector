//
//  AttributesInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol AttributesInspectorViewModelProtocol: ElementViewHierarchyPanelViewModelProtocol {
    var sectionViewModels: [HiearchyInspectableElementViewModelProtocol] { get }
    
    var isHighlightingViews: Bool { get }
    
    var isLiveUpdating: Bool { get set }
}

final class AttributesInspectorViewModel {
    var isHighlightingViews: Bool {
        reference.isHidingHighlightViews == false
    }
    
    var isLiveUpdating: Bool
    
    let reference: ViewHierarchyReference
    
    let snapshot: ViewHierarchySnapshot
    
    private(set) lazy var sectionViewModels: [HiearchyInspectableElementViewModelProtocol] = {
        guard let referenceView = reference.view else {
            return []
        }
        
        return snapshot.inspectableElements.compactMap { section in
            guard section.targets(object: referenceView) else {
                return nil
            }
            
            return section.viewModel(with: referenceView)
        }
    }()
    
    init(
        reference: ViewHierarchyReference,
        snapshot: ViewHierarchySnapshot
    ) {
        self.reference = reference
        self.snapshot = snapshot
        self.isLiveUpdating = true
    }
}

// MARK: - AttributesInspectorViewModelProtocol

extension AttributesInspectorViewModel: AttributesInspectorViewModelProtocol {
    var parent: ElementViewHierarchyPanelViewModelProtocol? {
        get { nil }
        set { }
    }
    
    var thumbnailImage: UIImage? { snapshot.iconImage(for: reference.view) }
    
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
