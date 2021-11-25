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

extension UIViewController: ViewHierarchyNodeRelationship {
    typealias Node = UIViewController

    var isHidden: Bool {
        get { view.isHidden }
        set { view.isHidden = newValue }
    }

    var frame: CGRect {
        view.frame
    }

    var window: UIWindow? {
        view.window
    }

    var canHostContextMenuInteraction: Bool {
        if isViewLoaded { return view.canHostContextMenuInteraction }
        return false
    }

    var canHostInspectorView: Bool {
        if isViewLoaded { return view.canHostInspectorView }
        return false
    }

    var topPresentedViewController: UIViewController? {
        presentedViewController?.topPresentedViewController ?? self
    }

    var allParents: [UIViewController] {
        var array = [UIViewController]()

        if let parent = parent {
            array.append(parent)
            array.append(contentsOf: parent.allParents)
        }

        return array.filter { !($0.view is LayerViewProtocol) }
    }

    var allChildren: [UIViewController] {
        children.flatMap { [$0] + $0.allChildren }
    }
}
