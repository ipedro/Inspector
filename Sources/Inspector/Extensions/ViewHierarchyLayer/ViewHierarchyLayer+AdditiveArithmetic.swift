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

import Foundation

extension ViewHierarchyLayer: AdditiveArithmetic {
    public static func - (lhs: Inspector.ViewHierarchyLayer, rhs: Inspector.ViewHierarchyLayer) -> Inspector.ViewHierarchyLayer {
        ViewHierarchyLayer(
            name: [lhs.name, rhs.name].joined(separator: ",-"),
            showLabels: lhs.showLabels,
            allowsInternalViews: lhs.allowsInternalViews
        ) {
            lhs.filter($0) && rhs.filter($0) == false
        }
    }

    public static func + (lhs: Inspector.ViewHierarchyLayer, rhs: Inspector.ViewHierarchyLayer) -> Inspector.ViewHierarchyLayer {
        ViewHierarchyLayer(
            name: [lhs.name, rhs.name].joined(separator: ",+"),
            showLabels: lhs.showLabels,
            allowsInternalViews: lhs.allowsInternalViews
        ) {
            lhs.filter($0) || rhs.filter($0)
        }
    }

    public static var zero: Inspector.ViewHierarchyLayer {
        ViewHierarchyLayer(name: "zero", showLabels: false) { _ in false }
    }
}
