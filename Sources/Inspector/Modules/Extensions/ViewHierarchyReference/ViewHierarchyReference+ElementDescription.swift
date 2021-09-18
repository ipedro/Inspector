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
import UIKit

extension ViewHierarchyReference {
    var elementDescription: String {
        [
            classNameDescription,
            frameDescription,
            subviewsDescription,
            constraintsDescription,
            warningsDescription,
        ]
        .compactMap { $0 }
        .joined(separator: "\n")
    }
}

extension ViewHierarchyReference {
    var constraintsDescription: String? {
        let totalCount = constraintReferences.count

        if totalCount == .zero {
            return nil
        }
        else {
            return totalCount == 1 ? "1 Constraint" : "\(totalCount) Constraints"
        }
    }

    var warningsDescription: String? {
        let warnings = [
            emptyFrame,
            isUserInteractionDisabled,
            isControlDisabled
        ]
        .compactMap { $0 }

        if warnings.isEmpty {
            return nil
        }

        return warnings.joined(separator: "\n").string(prepending: "\n")
    }

    private var emptyFrame: String? {
        guard
            let view = rootView,
            view.frame.isEmpty
        else {
            return nil
        }

        return "⚠️ Frame is empty"
    }

    private var isUserInteractionDisabled: String? {
        guard
            let view = rootView,
            view.isUserInteractionEnabled == false
        else { return nil }

        return "⚠️ User interaction disabled"
    }

    private var isControlDisabled: String? {
        guard
            let control = rootView as? UIControl,
            control.isEnabled == false
        else {
            return nil
        }

        return "⚠️ Control is disabled"
    }

    var subviewsDescription: String? {
        guard isContainer else { return nil }

        let child = children.count == 1 ? "1 Child" : "\(children.count) Children"
        let subview = flattenedSubviewReferences.count == 1 ? "1 Subview" : "\(flattenedSubviewReferences.count) Subviews"

        return "\(child) (\(subview))"
    }

    var frameDescription: String? {
        guard let view = rootView else { return nil }

        let origin = [
            view.frame.origin.x.toString(prepending: "X:", separator: " "),
            view.frame.origin.y.toString(prepending: "Y:", separator: " ")
        ].joined(separator: " — ")

        let size = [
            view.frame.size.width.toString(prepending: "W:", separator: " "),
            view.frame.size.height.toString(prepending: "H:", separator: " ")
        ].joined(separator: " — ")

        return "Position: \(origin)\nSize: \(size)"
    }

    var superclassName: String? {
        guard
            let view = rootView,
            let superclass = view.superclass
        else {
            return nil
        }

        return String(describing: superclass)
    }

    var classNameDescription: String? {
        guard let view = rootView else { return nil}

        guard let superclassName = superclassName else {
            return view.className
        }

        return "\(view.className) (\(superclassName))"
    }

}
