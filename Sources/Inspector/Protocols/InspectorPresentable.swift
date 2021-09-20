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

public protocol InspectorPresentable {}

extension InspectorPresentable {

    private var manager: Manager { Inspector.manager }

    var isInspectingHierarchy: Bool { manager.isInspectingHierarchy }

    func isInspecting(_ element: UIView) -> Bool {
        element.allSubviews.contains { $0 is InternalViewProtocol }
    }

    public func inspect(_ element: UIView, animated: Bool = true) {
        manager.presentElementInspector(for: .init(element), animated: animated, from: element)
    }

    public func inspect(_ layer: Inspector.ViewHierarchyLayer) {
        manager.installLayer(layer)
    }

    public func inspectAll() {
        manager.installAllLayers()
    }

    public func stopInspecting(_ layer: Inspector.ViewHierarchyLayer) {
        manager.removeLayer(layer)
    }

    public func stopInspectingAll() {
        manager.removeAllLayers()
    }

    public func presentInspector(animated: Bool = true) {
        manager.presentInspector(animated: animated)
    }
}

extension UIView: InspectorPresentable {}

extension UIViewController: InspectorPresentable {}
