//
//  ViewHierarchySnapshot.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

struct ViewHierarchySnapshot {
    
    // MARK: - Properties
    
    let expiryDate: Date = Date().addingTimeInterval(HierarchyInspector.configuration.cacheExpirationTimeInterval)
    
    let availableLayers: [ViewHierarchyLayer]
    
    let populatedLayers: [ViewHierarchyLayer]
    
    let emptyLayers: [ViewHierarchyLayer]
    
    let viewHierarchy: ViewHierarchyReference
    
    let flattenedViewHierarchy: [ViewHierarchyReference]
    
    let inspectableElements: [HierarchyInspectorElementLibraryProtocol]
    
    init(
        availableLayers: [ViewHierarchyLayer],
        inspectableElements: [HierarchyInspectorElementLibraryProtocol],
        in rootView: UIView
    ) {
        self.availableLayers = availableLayers.uniqueValues
        
        self.inspectableElements = inspectableElements
        
        viewHierarchy = ViewHierarchyReference(root: rootView)
        
        flattenedViewHierarchy = viewHierarchy.flattenedInspectableViewReferences
        
        let inspectableViews = viewHierarchy.flattenedInspectableViewReferences.compactMap { $0.rootView }
        
        populatedLayers = availableLayers.filter { $0.filter(flattenedViewHierarchy: inspectableViews).isEmpty == false }
        
        emptyLayers = Array(Set(availableLayers).subtracting(populatedLayers))
    }
    
}

// MARK: - Icon

extension ViewHierarchySnapshot {
    
    func iconImage(for view: UIView?, with size: CGSize = .defaultElementIconSize) -> UIImage {
        iconImage(for: view).resized(size)
    }
    
    private func iconImage(for view: UIView?) -> UIImage {
        switch view {
        case is BaseView:
            return UIImage.moduleImage(named: "InternalView-32_Normal").withRenderingMode(.alwaysTemplate)
            
        case is BaseControl:
            return UIImage.moduleImage(named: "InternalView-32_Normal").withRenderingMode(.alwaysOriginal)
         
        case let view?:
            let icons = inspectableElements.targeting(element: view).compactMap { $0.icon(with: view) }
            
            if let firstIcon = icons.first {
                return firstIcon
            }
            
        default:
            break
        }
        
        return UIImage.moduleImage(named: "EmptyView-32_Normal")
    }
    
}

private extension CGSize {
    static let defaultElementIconSize = CGSize(
        width:  ElementInspector.appearance.verticalMargins * 3,
        height: ElementInspector.appearance.verticalMargins * 3
    )
}
