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
    
    init(view: UIView) {
        self.view = view
        
        viewIdentifier = ObjectIdentifier(view)
        
        canPresentOnTop = view.canPresentOnTop
        
        className = view.className
        
        elementName = view.elementName
        
        isSystemView = view.isSystemView
        
        canHostInspectorView = view.canHostInspectorView
        
        children = view.originalSubviews.map { ViewHierarchyReference(view: $0) }
    }
}

// MARK: - ViewHierarchy {

extension ViewHierarchyReference: ViewHierarchy {
    
    private var viewHierarchy: [ViewHierarchyReference] {
        let array = children + children.flatMap { $0.viewHierarchy }
        
        return array
    }
    
    var inspectableViewHierarchy: [ViewHierarchyReference] {
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
