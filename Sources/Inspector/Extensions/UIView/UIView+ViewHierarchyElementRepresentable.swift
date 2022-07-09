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
        allSuperviews
            .filter { $0 is InternalViewProtocol == false }
    }

    var allSuperviews: [UIView] {
        var superviews = [UIView]()
        if let superview = superview {
            superviews.append(superview)
            superviews.append(contentsOf: superview.allSuperviews)
        }
        return superviews
    }

    var children: [UIView] {
        subviews.filter { $0 is InternalViewProtocol == false }
    }

    var allChildren: [UIView] {
        children.reversed().flatMap { [$0] + $0.allChildren }
    }

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        .init(rawValue: overrideUserInterfaceStyle) ?? .unspecified
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
            self is UIWindow == false &&
            className != "UITransitionView" &&
            className != "UIDropShadowView" &&
            className != "_UIModernBarButton"
    }

    var canHostInspectorView: Bool {
        let className = _className
        let superViewClassName = superview?._className ?? ""

        guard
            className != "UIRemoteKeyboardWindow",
            className != "UITextEffectsWindow",
            className != "UIEditingOverlayGestureView",
            className != "UIInputSetContainerView",

            // Avoid breaking UINavigationController large title.
            superViewClassName != "UIViewControllerWrapperView",

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

            // Skip custom classes
            Inspector.sharedInstance.configuration.nonInspectableClassNames.contains(className) == false,
            Inspector.sharedInstance.configuration.nonInspectableClassNames.contains(superViewClassName) == false
        else {
            return false
        }
        return true
    }

    var elementName: String {
        accessibilityIdentifier?.trimmed ?? _classNameWithoutQualifiers
    }

    var displayName: String {
        let prettyName = accessibilityIdentifier?.trimmed ?? _prettyClassNameWithoutQualifiers

        guard
            let textElement = self as? TextElement,
            let textContent = textElement.content?.replacingOccurrences(of: "\n", with: "\\n")
        else {
            return prettyName
        }

        let limit = 20

        let formattedText: String = {
            guard textContent.count > limit else { return textContent }
            return textContent
                .prefix(limit)
                .appending("…")
        }()

        return "\(prettyName) - \"\(formattedText)\""
    }

    var shortElementDescription: String {
        ["Class Name: \(_className)",
         frameDescription,
         subviewsDescription]
            .compactMap { $0 }
            .joined(separator: .newLine)
    }
    
    var elementDescriptionComponents: [String: String?] { [
        "Constraints": constraintsDescription,
        "Issues": issuesDescription?.string(prepending: .newLine),
        "Accessibility ID": {
            guard let accessibilityIdentifier = accessibilityIdentifier else { return .none }
            return "\"\(accessibilityIdentifier)\""
        }()
    ] }

    var elementDescription: String {
        let fullDescription = elementDescriptionComponents
            .keys
            .sorted(by: <)
            .reduce(shortElementDescription) { partialResult, key in
                guard
                    let value = elementDescriptionComponents[key],
                    let value = value
                else { return partialResult }
                return partialResult
                    .appending(String.newLine)
                    .appending("\(key): \(value)")
            }
        
        guard let accessibilityDescription = accessibilityLabel?.trimmed else {
            return fullDescription
        }
        return "\"\(accessibilityDescription)\"\n\n\(fullDescription)"
    }
}

private extension UIView {
    var subviewsDescription: String? {
        guard isContainer else { return .none }
        
        let childrenCount = children.count
        let allChildrenCount = allChildren.count
        
        let subviews: String = {
            switch childrenCount {
            case 1:
                return "1 Subview"
            case let count:
                return "\(count) Subviews"
            }
        }()
        
        guard allChildrenCount > childrenCount else {
            return subviews
        }
        
        return "\(subviews) (\(allChildrenCount) Total)"
    }

    private static let frameFormatter = NumberFormatter().then {
        $0.numberStyle = .decimal
        $0.maximumFractionDigits = 1
    }

    var frameDescription: String? {
        ["X: \(Self.frameFormatter.string(from: frame.origin.x)!)",
         "Y: \(Self.frameFormatter.string(from: frame.origin.y)!)",
         "—",
         "W: \(Self.frameFormatter.string(from: frame.size.width)!)",
         "H: \(Self.frameFormatter.string(from: frame.size.height)!)"]
        .joined(separator: " ")
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
        switch constraintElements.count {
        case .zero:
            return .none
        case 1:
            return constraintElements.first?.displayName
        case let count:
            guard let bla = constraintElements.map(\.second).count = 
            return "\(count) Constraints"
        }
    }
}

extension NSObject {
    var _isInternalView: Bool {
        _className.starts(with: "_")
    }

    var _isSystemContainer: Bool {
        let className = _classNameWithoutQualifiers

        for systemContainer in Inspector.sharedInstance.configuration.knownSystemContainers {
            if className == systemContainer || className.starts(with: "_UI") {
                return true
            }
        }

        return false
    }

    var _className: String {
        String(describing: classForCoder)
    }

    var _prettyClassNameWithoutQualifiers: String {
        _classNameWithoutQualifiers
            .replacingOccurrences(of: "_", with: "")
            .camelCaseToWords()
            .replacingOccurrences(of: " Kit ", with: "Kit ")
            .removingRegexMatches(pattern: "[A-Z]{2} ", options: .anchored)
            .trimmingCharacters(in: .whitespacesAndNewlines)
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
