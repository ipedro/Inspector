//
//  ViewHierarchySnapshot.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

struct ViewHierarchySnapshot {
    
    // MARK: - Properties
    
    static var cacheExpirationTimeInterval: TimeInterval = 0.5
    
    let expiryDate: Date = Date().addingTimeInterval(Self.cacheExpirationTimeInterval)
    
    let availableLayers: [ViewHierarchyLayer]
    
    let populatedLayers: [ViewHierarchyLayer]
    
    let emptyLayers: [ViewHierarchyLayer]
    
    let viewHierarchy: ViewHierarchyReference
    
    let flattenedViewHierarchy: [ViewHierarchyReference]
    
    let inspectableElements: [HierarchyInspectableElementProtocol]
    
    init(
        availableLayers: [ViewHierarchyLayer],
        inspectableElements: [HierarchyInspectableElementProtocol],
        in rootView: UIView
    ) {
        self.availableLayers = availableLayers.uniqueValues
        
        self.inspectableElements = inspectableElements
        
        viewHierarchy = ViewHierarchyReference(root: rootView)
        
        flattenedViewHierarchy = viewHierarchy.flattenedInspectableViews
        
        let inspectableViews = viewHierarchy.flattenedInspectableViews.compactMap { $0.rootView }
        
        populatedLayers = availableLayers.filter { $0.filter(flattenedViewHierarchy: inspectableViews).isEmpty == false }
        
        emptyLayers = Array(Set(availableLayers).subtracting(populatedLayers))
    }
    
    var inspectableViews: [UIView] {
        viewHierarchy.flattenedInspectableViews.compactMap { $0.rootView }
    }
    
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
