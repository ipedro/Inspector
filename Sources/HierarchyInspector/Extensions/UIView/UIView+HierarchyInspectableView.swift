//
//  UIView+HierarchyInspectableView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectableView

extension UIView: HierarchyInspectableView {
    
    var rawViewHierarchy: [UIView] {
        subviews + subviews.flatMap { $0.rawViewHierarchy }
    }
    
    var inspectableViewHierarchy: [HierarchyInspectableView] {
        ([self] + rawViewHierarchy).filter { $0.canHostInspectorView }
    }
    
    var originalSubviews: [UIView] {
        subviews.filter { $0 is View == false }
    }

    var canHostInspectorView: Bool {
        guard
            // Adding subviews directly to a UIVisualEffectView throws runtime exception.
            self is UIVisualEffectView == false,
            
            // Avoid breaking UIButton layout.
            superview is UIButton == false,
            
            // Avoid breaking UITableView self sizing cells.
            className != "UITableViewCellContentView",
            
            // Avoid breaking UINavigationController large title.
            superview?.className != "UIViewControllerWrapperView",
            
            // Skip hierarchy inspector internal strcutures.
            self is HierarchyInspectorView == false,
            superview is HierarchyInspectorView == false
        else {
            return false
        }

        return true
    }
    
    var isSystemView: Bool {
        className.first == "_"
    }
    
    var className: String {
        String(describing: classForCoder)
    }
    
    var elementName: String {
        guard let description = accessibilityIdentifier?.split(separator: ".").last else {
            return className
        }
        
        return String(description)
    }
}
