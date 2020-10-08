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
    
    private(set) var children: [ViewHierarchyReference] {
        didSet {
            deepestAbsoulteLevel = children.map { $0.depth }.max() ?? depth
        }
    }
    
    let viewIdentifier: ObjectIdentifier
    
    let isSystemView: Bool
    
    let className: String
    
    let elementName: String
    
    let frame: CGRect
    
    let accessibilityIdentifier: String?
    
    private(set) var deepestAbsoulteLevel: Int
    
    var deepestRelativeLevel: Int {
        deepestAbsoulteLevel - depth
    }
    
    var depth: Int {
        didSet {
            guard let view = view else {
                children = []
                return
            }
            
            children = view.originalSubviews.map { ViewHierarchyReference(root: $0, depth: depth + 1) }
        }
    }
    
    init(root: UIView, depth: Int = 0) {
        self.view = root
        
        self.depth = depth
        
        viewIdentifier = ObjectIdentifier(root)
        
        canPresentOnTop = root.canPresentOnTop
        
        className = root.className
        
        elementName = root.elementName
        
        isSystemView = root.isSystemView
        
        frame = root.frame
        
        accessibilityIdentifier = root.accessibilityIdentifier
        
        canHostInspectorView = root.canHostInspectorView
        
        children = root.originalSubviews.map { ViewHierarchyReference(root: $0, depth: depth + 1) }
        
        deepestAbsoulteLevel = children.map { $0.depth }.max() ?? depth
    }
}

// MARK: - ViewHierarchyProtocol {

extension ViewHierarchyReference: ViewHierarchyProtocol {
    
    var flattenedViewHierarchy: [ViewHierarchyReference] {
        let array = children.flatMap { [$0] + $0.flattenedViewHierarchy }
        
        return array
    }
    
    var flattenedInspectableViews: [ViewHierarchyReference] {
        let array = ([self] + flattenedViewHierarchy).filter { $0.canHostInspectorView }
        
        return array
    }
    
}

// MARK: - Hashable

extension ViewHierarchyReference: Hashable {
    func hash(into hasher: inout Hasher) {
        viewIdentifier.hash(into: &hasher)
    }
}
