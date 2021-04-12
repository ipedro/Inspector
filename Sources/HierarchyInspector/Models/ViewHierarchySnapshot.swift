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
        
        let inspectableViews = viewHierarchy.flattenedInspectableViews.compactMap { $0.view }
        
        populatedLayers = availableLayers.filter { $0.filter(flattenedViewHierarchy: inspectableViews).isEmpty == false }
        
        emptyLayers = Array(Set(availableLayers).subtracting(populatedLayers))
    }
    
    var inspectableViews: [UIView] {
        viewHierarchy.flattenedInspectableViews.compactMap { $0.view }
    }
    
    func iconImage(for view: UIView?, with size: CGSize = .defaultElementIconSize) -> UIImage {
        
        let defaultImage = UIImage.moduleImage(named: "EmptyView-32_Normal")
        
        guard let view = view else {
            return defaultImage
        }
        
        if
            let imageView = view as? UIImageView,
            let image = imageView.image
        {
            return image.resized(size)
        }
        
        let images = inspectableElements.compactMap { section -> UIImage? in
            guard
                section.targets(object: view),
                let image = section.icon?.resized(size)
            else {
                return nil
            }
            return image
        }
        
        return images.first ?? defaultImage
    }
    
}
