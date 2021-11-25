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

extension UIView: ViewHierarchyElementDescription {
    var isInternalType: Bool {
        className.first == "_" &&
        className.isInternalType
    }

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        if #available(iOS 13.0, *) {
            return .init(rawValue: overrideUserInterfaceStyle) ?? .unspecified
        } else {
            return .unspecified
        }
    }

    var issues: [ViewHierarchyIssue] { ViewHierarchyIssue.issues(for: self) }

    var constraintElements: [LayoutConstraintElement] {
        constraints
            .compactMap { LayoutConstraintElement(with: $0, in: self) }
            .uniqueValues()
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
            .joined(separator: .newLine)
    }

    var elementDescription: String {
        [classNameDescription,
         sizeDescription,
         positionDescrpition,
         constraintsDescription,
         subviewsDescription,
         issuesDescription?.string(prepending: .newLine)]
            .compactMap { $0 }
            .joined(separator: .newLine)
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

    var subviewsDescription: String? {
        guard isContainer else { return nil }

        let children = children.count == 1 ? "1 Child" : "\(children.count) Children"
        let subviews = allChildren.count == 1 ? "1 Subview" : "\(allChildren.count) Subviews"

        return "\(children) (\(subviews))"
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
                multipleIssuesDescription?.append(.newLine)
                multipleIssuesDescription?.append("• \(issue.description)")
            }
        }
    }

    var constraintsDescription: String? {
        let totalCount = constraintElements.count

        if totalCount == .zero {
            return nil
        }
        else {
            return totalCount == 1 ? "1 Constraint" : "\(totalCount) Constraints"
        }
    }
}
