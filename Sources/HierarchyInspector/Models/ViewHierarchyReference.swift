//
//  ViewHierarchyReference.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 05.10.20.
//

import UIKit

final class ViewHierarchyReference {
    weak var rootView: UIView?
    
    let canPresentOnTop: Bool
    
    let canHostInspectorView: Bool
    
    let viewIdentifier: ObjectIdentifier
    
    let isSystemView: Bool
    
    let className: String
    
    let elementName: String
    
    let frame: CGRect
    
    let accessibilityIdentifier: String?
    
    var parent: ViewHierarchyReference?
    
    private(set) lazy var isContainer: Bool = children.isEmpty == false
    
    private(set) lazy var deepestAbsoulteLevel: Int = children.map { $0.depth }.max() ?? depth
    
    private(set) lazy var children: [ViewHierarchyReference] = rootView?.originalSubviews.map { ViewHierarchyReference(root: $0, depth: depth + 1, parent: self) } ?? []
    
    var deepestRelativeLevel: Int {
        deepestAbsoulteLevel - depth
    }
    
    var depth: Int {
        didSet {
            guard let view = rootView else {
                children = []
                return
            }
            
            children = view.originalSubviews.map { ViewHierarchyReference(root: $0, depth: depth + 1, parent: self) }
        }
    }
    
    init(root: UIView, depth: Int = 0, parent: ViewHierarchyReference? = nil) {
        self.rootView = root
        
        self.depth = depth
        
        self.parent = parent
        
        viewIdentifier = ObjectIdentifier(root)
        
        canPresentOnTop = root.canPresentOnTop
        
        className = root.className
        
        elementName = root.elementName
        
        isSystemView = root.isSystemView
        
        frame = root.frame
        
        accessibilityIdentifier = root.accessibilityIdentifier
        
        canHostInspectorView = root.canHostInspectorView
    }
}

extension CGSize {
    static let defaultElementIconSize = CGSize(
        width: ElementInspector.appearance.verticalMargins * 3,
        height: ElementInspector.appearance.verticalMargins * 3
    )
}

// MARK: - ViewHierarchyProtocol {

extension ViewHierarchyReference: ViewHierarchyProtocol {
    
    var flattenedViewHierarchy: [ViewHierarchyReference] {
        let array = children.flatMap { [$0] + $0.flattenedViewHierarchy }
        
        return array
    }
    
    var flattenedInspectableViews: [ViewHierarchyReference] {
        flattenedViewHierarchy.filter { $0.canHostInspectorView }
    }
    
}

// MARK: - Hashable

extension ViewHierarchyReference: Hashable {
    static func == (lhs: ViewHierarchyReference, rhs: ViewHierarchyReference) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        viewIdentifier.hash(into: &hasher)
    }
}

extension ViewHierarchyReference {
    var isHidingHighlightViews: Bool {
        guard let view = rootView else {
            return false
        }
        
        for view in view.allSubviews where view is LayerViewProtocol {
            if view.isHidden {
                return true
            }
        }
        
        return false
    }
}
