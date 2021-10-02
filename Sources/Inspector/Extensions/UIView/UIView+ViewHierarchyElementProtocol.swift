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

extension UIView: ViewHierarchyElementProtocol {
    var isContainer: Bool {
        !originalSubviews.isEmpty
    }

    var viewIdentifier: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    var issues: [ViewHierarchyIssue] { ViewHierarchyIssue.issues(for: self) }

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
        let className = self.className
        let superViewClassName = superview?.className ?? ""

        guard
            // Adding subviews directly to a UIVisualEffectView throws runtime exception.
            self is UIVisualEffectView == false,

            // Adding subviews to UIPageViewController containers throws runtime exception.
            className != "_UIPageViewControllerContentView",
            subviews.map(\.className).contains("_UIPageViewControllerContentView") == false,
            className != "_UIQueuingScrollView",
            superViewClassName != "_UIQueuingScrollView",

            // Avoid breaking UIButton layout.
            superview is UIButton == false,

            // Avoid breaking UITableView self sizing cells.
            className != "UITableViewCellContentView",

            // Avoid breaking UINavigationController large title.
            superViewClassName != "UIViewControllerWrapperView",

            // Skip non inspectable views
            self is NonInspectableView == false,
            superview is NonInspectableView == false,

            // Skip custom classes
            Inspector.configuration.nonInspectableClassNames.contains(className) == false,
            Inspector.configuration.nonInspectableClassNames.contains(superViewClassName) == false
        else {
            return false
        }
        return true
    }

    var isSystemView: Bool {
        isSystemContainerView || className.starts(with: "_UI")
    }

    var isSystemContainerView: Bool {
        let className = classNameWithoutQualifiers

        for systemContainer in Inspector.configuration.knownSystemContainers where className == systemContainer {
            return true
        }

        return false
    }

    var className: String {
        String(describing: classForCoder)
    }

    var classNameWithoutQualifiers: String {
        guard let nameWithoutQualifiers = className.split(separator: "<").first else {
            return className
        }

        return String(nameWithoutQualifiers)
    }

    var elementName: String {
        guard let description = accessibilityIdentifier?.split(separator: ".").last else {
            return classNameWithoutQualifiers
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

    var shortElementDescription: String {
        [subviewsDescription,
         constraintsDescription,
         positionDescrpition,
         sizeDescription,
         superclassName,
         className]
            .compactMap { $0 }
            .prefix(3)
            .joined(separator: "\n")
    }

    var elementDescription: String {
        [classNameDescription,
         sizeDescription,
         positionDescrpition,
         constraintsDescription,
         subviewsDescription,
         issuesDescription?.string(prepending: "\n")]
            .compactMap { $0 }
            .joined(separator: "\n")
    }
}

private extension UIView {
    var positionDescrpition: String? {
        let position = [
            frame.origin.x.toString(prepending: "X:", separator: " "),
            frame.origin.y.toString(prepending: "Y:", separator: " ")
        ].joined(separator: " — ")
        return "Position: \(position)"
    }

    var superclassName: String? {
        guard let superclass = superclass else { return nil }
        return String(describing: superclass)
    }

    var subviewsDescription: String? {
        guard isContainer else { return nil }

        let child = originalSubviews.count == 1 ? "1 Child" : "\(originalSubviews.count) Children"
        let subview = allOriginalSubviews.count == 1 ? "1 Subview" : "\(allOriginalSubviews.count) Subviews"

        return "\(child) (\(subview))"
    }

    var sizeDescription: String? {
        let size = [
            frame.size.width.toString(prepending: "W:", separator: " "),
            frame.size.height.toString(prepending: "H:", separator: " ")
        ].joined(separator: " — ")

        return "Size: \(size)"
    }

    var classNameDescription: String? {
        guard let superclassName = superclassName else {
            return className
        }

        return "\(className) (\(superclassName))"
    }

    var issuesDescription: String? {
        guard !issues.isEmpty else { return nil }

        if issues.count == 1, let issue = issues.first {
            return "⚠️ \(issue.description)"
        }

        return issues.reduce(into: "") { multipleIssuesDescription, issue in
            if multipleIssuesDescription?.isEmpty == true {
                multipleIssuesDescription = "⚠️ \(issues.count) Issues"
            }
            else {
                multipleIssuesDescription?.append("\n")
                multipleIssuesDescription?.append("• \(issue.description)")
            }
        }
    }

    var constraintsDescription: String? {
        let totalCount = constraintReferences.count

        if totalCount == .zero {
            return nil
        }
        else {
            return totalCount == 1 ? "1 Constraint" : "\(totalCount) Constraints"
        }
    }
}
