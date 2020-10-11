//
//  ViewHierarchyLayer.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public struct ViewHierarchyLayer {
    public typealias Filter = (UIView) -> Bool
    
    // MARK: - Properties
    
    public let name: String
    
    public let filter: Filter
    
    let showLabels: Bool
    
    let allowsSystemViews: Bool
    
    // MARK: - Init
    
    public static func layer(name: String, filter: @escaping Filter) -> Self {
        self.init(name: name, showLabels: true, allowsSystemViews: false, filter: filter)
    }
    
    init(name: String, showLabels: Bool, allowsSystemViews: Bool = false, filter: @escaping Filter) {
        self.name = name
        self.showLabels = showLabels
        self.allowsSystemViews = allowsSystemViews
        self.filter = filter
    }
    
    // MARK: - Metods
    
    func filter(snapshot: ViewHierarchySnapshot) -> [UIView] {
        let inspectableViews = snapshot.flattenedViewHierarchy.compactMap { $0.view }
        
        return filter(flattenedViewHierarchy: inspectableViews)
    }
    
    func filter(flattenedViewHierarchy: [UIView]) -> [UIView] {
        let filteredViews = flattenedViewHierarchy.filter(filter)
        
        switch allowsSystemViews {
        case true:
            return filteredViews
            
        case false:
            return filteredViews.filter { $0.isSystemView == false }
        }
    }
    
}

// MARK: - Internal Layers

extension ViewHierarchyLayer {
    
    static let wireframes = ViewHierarchyLayer(name: "Wireframes", showLabels: false) { _ in true }
    
    #if DEBUG
    #warning("TODO: investigate if this `if` clause makes sense")
    static let internalViews = ViewHierarchyLayer(name: "Internal views", showLabels: true, allowsSystemViews: true) { $0.isSystemView }
    #endif
    
}