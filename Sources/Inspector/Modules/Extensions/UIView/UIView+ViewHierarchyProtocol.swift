//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

// MARK: - ViewHierarchyProtocol

extension UIView: ViewHierarchyProtocol {
    var constraintReferences: [NSLayoutConstraintInspectableViewModel] {
        constraints.compactMap { constraint in
            NSLayoutConstraintInspectableViewModel(with: constraint, in: self)
        }
        .uniqueValues()
    }

    var horizontalConstraintReferences: [NSLayoutConstraintInspectableViewModel] {
        constraintReferences.filter { $0.axis == .horizontal }
    }

    var verticalConstraintReferences: [NSLayoutConstraintInspectableViewModel] {
        constraintReferences.filter { $0.axis == .vertical }
    }

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
            
            // Adding subviews to UIPageViewController containers throws runtime exception.
            className != "_UIPageViewControllerContentView",
            subviews.map(\.className).contains("_UIPageViewControllerContentView") == false,
            className != "_UIQueuingScrollView",
            superview?.className != "_UIQueuingScrollView",
            
            // Avoid breaking UIButton layout.
            superview is UIButton == false,
            
            // Avoid breaking UITableView self sizing cells.
            className != "UITableViewCellContentView",
            
            // Avoid breaking UINavigationController large title.
            superview?.className != "UIViewControllerWrapperView",
            
            // Skip hierarchy inspector internal strcutures.
            self is LayerViewProtocol == false,
            superview is LayerViewProtocol == false
        else {
            return false
        }
        return true
    }
    
    var isSystemView: Bool {
        guard
            isSystemContainerView == false,
            className.first != "_"
        else {
            return true
        }
        
        return false
    }
    
    var isSystemContainerView: Bool {
        guard
            className != "UIWindow",
            className != "UITransitionView",
            className != "UIDropShadowView",
            className != "UILayoutContainerView",
            className != "UIViewControllerWrapperView",
            className != "UINavigationTransitionView"
        else {
            return true
        }
        
        return false
    }
    
    var className: String {
        String(describing: classForCoder)
    }

    var accessibilityIdentifierOrClassName: String {
        accessibilityIdentifier ?? className
    }
    
    var elementName: String {
        guard let description = accessibilityIdentifier?.split(separator: ".").last else {
            return className
        }
        
        return String(description)
    }
    
    var displayName: String {
        // prefer text content
        if let textContent = (self as? TextElement)?.content {
            return "\"" + textContent + "\""
        }
        
        return elementName
    }
}
