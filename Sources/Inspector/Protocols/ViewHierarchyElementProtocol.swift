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

protocol ViewHierarchyElementProtocol {
    var viewIdentifier: ObjectIdentifier { get }

    /// Determines if a view can host an inspector view.
    var canHostInspectorView: Bool { get }

    var isInternalView: Bool { get }

    /// String representation of the class name.
    var className: String { get }

    /// /// String representation of the class name without Generics signature.
    var classNameWithoutQualifiers: String { get }

    /// If a view has accessibility identifiers the last component will be shown, otherwise shows the class name.
    var elementName: String { get }

    var displayName: String { get }

    var canPresentOnTop: Bool { get }

    var isUserInteractionEnabled: Bool { get }

    var frame: CGRect { get }

    var accessibilityIdentifier: String? { get }

    var isContainer: Bool { get }

    // MARK: - Issues

    var hasIssues: Bool { get }

    var issues: [ViewHierarchyIssue] { get }

    // MARK: - Constraints

    var constraintReferences: [NSLayoutConstraintInspectableViewModel] { get }

    var horizontalConstraintReferences: [NSLayoutConstraintInspectableViewModel] { get }

    var verticalConstraintReferences: [NSLayoutConstraintInspectableViewModel] { get }

    // MARK: - Description

    var shortElementDescription: String { get }

    var elementDescription: String { get }
}

extension ViewHierarchyElementProtocol {
    var hasIssues: Bool { !issues.isEmpty }
}