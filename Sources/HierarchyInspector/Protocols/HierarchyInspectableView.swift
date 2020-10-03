//
//  HierarchyInspectableView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

protocol HierarchyInspectableView: UIView {
    /// Determines if a view can host an inspector view.
    var canHostInspectorView: Bool { get }
    
    var isSystemView: Bool { get }
    
    /// String representation of the class name.
    var className: String { get }
    
    /// If a view has accessibility identifiers the last component will be shown, otherwise shows the class name.
    var elementName: String { get }
    
    var rawViewHierarchy: [UIView] { get }
    
    var inspectableViewHierarchy: [HierarchyInspectableView] { get }
    
    var originalSubviews: [UIView] { get }
}

extension HierarchyInspectableView {
    
    func find(highlightViewsNamed name: String) ->  [HighlightView] {
        subviews.compactMap {
            guard
                let highlightView = $0 as? HighlightView,
                highlightView.name == name
            else {
                return nil
            }
            
            return highlightView
        }
    }
    
}
