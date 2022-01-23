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

extension UIView: ViewHierarchyElementRepresentable {
    var depth: Int {
        allParents.count
    }

    var parent: UIView? {
        superview
    }

    var isContainer: Bool { !children.isEmpty }

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

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        if #available(iOS 13.0, *) {
            return .init(rawValue: overrideUserInterfaceStyle) ?? .unspecified
        } else {
            return .unspecified
        }
    }

    var isInternalView: Bool {
        _isInternalView
    }

    var isSystemContainer: Bool {
        _isSystemContainer
    }

    var className: String {
        _className
    }

    var classNameWithoutQualifiers: String {
        _classNameWithoutQualifiers
    }

    var objectIdentifier: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    var isAssociatedToWindow: Bool {
        window != nil || self is UIWindow
    }

    var issues: [ViewHierarchyIssue] { ViewHierarchyIssue.issues(for: self) }

    var constraintElements: [LayoutConstraintElement] {
        constraints
            .compactMap { LayoutConstraintElement(with: $0, in: self) }
            .uniqueValues()
    }

    var canPresentOnTop: Bool {
        // Avoid breaking UINavigationController large title.
        if let superViewClassName = superview?._className, superViewClassName == "UIViewControllerWrapperView" {
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

    var canHostContextMenuInteraction: Bool {
        canHostInspectorView &&
        className != "UIWindow" &&
        className != "UITransitionView" &&
        className != "UIDropShadowView" &&
        className != "_UIModernBarButton"
    }

    var canHostInspectorView: Bool {
        let className = self._className
        let superViewClassName = superview?._className ?? ""

        guard
            className != "UIRemoteKeyboardWindow",
            className != "UITextEffectsWindow",
            className != "UIEditingOverlayGestureView",
            className != "UIInputSetContainerView",
//            className != "TUISystemInputAssistantView",
            
            // Adding subviews directly to a UIVisualEffectView throws runtime exception.
            self is UIVisualEffectView == false,

            // Adding subviews to UIPageViewController containers throws runtime exception.
            className != "_UIPageViewControllerContentView",
            subviews.map(\._className).contains("_UIPageViewControllerContentView") == false,
            className != "_UIQueuingScrollView",
            superViewClassName != "_UIQueuingScrollView",

            // Avoid breaking UIButton layout.
            superview is UIButton == false,

            // Avoid breaking UITableView self sizing cells.
            className != "UITableViewCellContentView",

            // Skip non inspectable views
            self is NonInspectableView == false,
            superview is NonInspectableView == false,
            //allParents.filter({ $0 is NonInspectableView }).isEmpty,

            // Skip custom classes
            Inspector.configuration.nonInspectableClassNames.contains(className) == false,
            Inspector.configuration.nonInspectableClassNames.contains(superViewClassName) == false
        else {
            return false
        }
        return true
    }

    var elementName: String {
        prettyAccessibilityIdentifier ?? _classNameWithoutQualifiers
    }

    private var prettyAccessibilityIdentifier: String? {
        guard let subSequence = accessibilityIdentifier?.split(separator: ".").last else { return nil }
        return String(subSequence)
    }

    var displayName: String {
        switch (self, prettyAccessibilityIdentifier) {
        case let (textElement as TextElement, identifier):
            let name = identifier ?? textElement._classNameWithoutQualifiers
            if let textContent = textElement.content?.prefix(30) {
                return "\"\(textContent)\" (\(name))"
            }
            return "\(name) (Empty)"
            

        case let (anyView, identifier?):
            return "\(anyView._classNameWithoutQualifiers) (\(identifier))"

        case let (anyView, .none):
            return anyView._classNameWithoutQualifiers
        }
    }

    var shortElementDescription: String {
        [subviewsDescription,
         constraintsDescription,
         positionDescrpition,
         sizeDescription,
         _superclassName,
         _className]
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
        guard let superclassName = _superclassName else {
            return _className
        }

        return "\(_className) (\(superclassName))"
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

extension NSObject {
    var _isInternalView: Bool {
        _className.starts(with: "_")
    }

    var _isSystemContainer: Bool {
        let className = _classNameWithoutQualifiers

        for systemContainer in Inspector.configuration.knownSystemContainers {
            if className == systemContainer || className.starts(with: "_UI") {
                return true
            }
        }

        return false
    }

    var _className: String {
        String(describing: classForCoder)
    }

    var _superclassName: String? {
        guard let superclass = superclass else { return nil }
        return String(describing: superclass)
    }

    var _classNameWithoutQualifiers: String {
        guard let nameWithoutQualifiers = _className.split(separator: "<").first else {
            return _className
        }

        return String(nameWithoutQualifiers)
    }

}
