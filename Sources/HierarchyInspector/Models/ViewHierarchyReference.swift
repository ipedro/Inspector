//
//  ViewHierarchyReference.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 05.10.20.
//

import UIKit

struct ViewHierarchyReference {
    weak var view: UIView?
    
    let canPresentOnTop: Bool
    
    let canHostInspectorView: Bool
    
    let children: [ViewHierarchyReference]
    
    let viewIdentifier: ObjectIdentifier
    
    let isSystemView: Bool
    
    let className: String
    
    let elementName: String
    
    init(root: UIView) {
        self.view = root
        
        viewIdentifier = ObjectIdentifier(root)
        
        canPresentOnTop = root.canPresentOnTop
        
        className = root.className
        
        elementName = root.elementName
        
        isSystemView = root.isSystemView
        
        canHostInspectorView = root.canHostInspectorView
        
        children = root.originalSubviews.map { ViewHierarchyReference(root: $0) }
    }
}

// MARK: - ViewHierarchy {

extension ViewHierarchyReference: ViewHierarchy {
    
    private var viewHierarchy: [ViewHierarchyReference] {
        let array = children + children.flatMap { $0.viewHierarchy }
        
        return array
    }
    
    var flattenedInspectableViews: [ViewHierarchyReference] {
        let array = ([self] + viewHierarchy).filter { $0.canHostInspectorView }
        
        return array
    }
    
}

// MARK: - Hashable

extension ViewHierarchyReference: Hashable {
    func hash(into hasher: inout Hasher) {
        viewIdentifier.hash(into: &hasher)
    }
}
