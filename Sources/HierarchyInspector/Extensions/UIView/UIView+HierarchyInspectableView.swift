//
//  UIView+ViewHierarchy.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - ViewHierarchy@objc 

extension UIView: ViewHierarchy {
    var canPresentOnTop: Bool {
        switch self {
        case is UITextView:
            return true

        case is UIScrollView:
            return false

        default:
            return true
        }
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
            self is HierarchyInspectorViewProtocol == false,
            superview is HierarchyInspectorViewProtocol == false
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
