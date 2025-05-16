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

/// A protocol that represents the public interface of a UIView.
protocol ViewHierarchyElementRepresentable {
    var _canHostContextMenuInteraction: Bool { get }

    var _objectIdentifier: ObjectIdentifier { get }

    /// Determines if a view can host an inspector view.
    var _canHostInspectorView: Bool { get }

    var _isInternalView: Bool { get }

    var _isSystemContainer: Bool { get }

    /// String representation of the class name.
    var _className: String { get }

    /// /// String representation of the class name without Generics signature.
    var _classNameWithoutQualifiers: String { get }

    /// If a view has accessibility identifiers the last component will be shown, otherwise shows the class name.
    var _elementName: String { get }

    var _displayName: String { get }

    var _canPresentOnTop: Bool { get }

    var isUserInteractionEnabled: Bool { get }

    var _frame: HashableBox<CGRect> { get }

    var accessibilityIdentifier: String? { get }

    // MARK: - Issues

    var _issues: [ViewHierarchyIssue] { get }

    // MARK: - Constraints

    var _constraintElements: [LayoutConstraintElement] { get }

    // MARK: - Description

    var _shortElementDescription: String { get }

    var _elementDescription: String { get }

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle { get }

    var traitCollection: UITraitCollection { get }

    var isHidden: Bool { get set }
}

extension ViewHierarchyElementRepresentable {
    var _hasIssues: Bool { !_issues.isEmpty }
}
