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

extension UIView: ViewHierarchyNodeRelationship {
    typealias Node = UIView

    var view: UIView! { self }

    var isViewLoaded: Bool { true }

    var canHostContextMenuInteraction: Bool {
        if Inspector.configuration.blockLists.contextMenuInteraction.contains(className) {
            return false
        }
        return canHostInspectorView
    }
    var canPresentOnTop: Bool {
        // Avoid breaking UINavigationController large title.
        if let superViewClassName = superview?.className, superViewClassName == "UIViewControllerWrapperView" {
            return true
        }

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
        let className = self.className

        if
            self is NonInspectableView,
            Inspector.configuration.nonInspectableClassNames.contains(className),
            Inspector.configuration.blockLists.inspectorViewHost.contains(className)
        {
            return false
        }

        if
            let superview = superview,
            superview is NonInspectableView,
            Inspector.configuration.nonInspectableClassNames.contains(superview.className),
            Inspector.configuration.blockLists.inspectorSuperviewHost.contains(superview.className)
        {
            return false
        }

        if subviews.map(\.className).contains("_UIPageViewControllerContentView") {
            return false
        }

        return true
    }

    var parent: UIView? { superview }

    var allParents: [UIView] {
        var array = [UIView]()

        if let parent = parent {
            array.append(parent)
            array.append(contentsOf: parent.allParents)
        }

        return array.filter { !($0 is LayerViewProtocol) }
    }

    var children: [UIView] {
        subviews.filter { !($0 is LayerViewProtocol) }
    }

    var allChildren: [UIView] {
        children.reversed().flatMap { [$0] + $0.allChildren }
    }
}
