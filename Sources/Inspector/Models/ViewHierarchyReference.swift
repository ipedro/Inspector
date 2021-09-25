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

final class ViewHierarchyReference {
    weak var rootView: UIView?

    var parent: ViewHierarchyReference?

    var isUserInteractionEnabled: Bool

    typealias IconProvider = (UIView?) -> UIImage?

    private let iconProvider: IconProvider

    weak private(set) var viewController: UIViewController?

    var depth: Int {
        didSet {
            guard let view = rootView else {
                children = []
                return
            }

            children = view.originalSubviews.map { .init($0, depth: depth + 1, iconProvider: iconProvider, parent: self) }
        }
    }

    // MARK: - Read only Properties

    let canPresentOnTop: Bool

    let canHostInspectorView: Bool

    let identifier: ObjectIdentifier

    let isSystemView: Bool

    let frame: CGRect

    let accessibilityIdentifier: String?

    private(set) lazy var issues = ViewHierarchyIssue.issues(for: self)

    var hasIssues: Bool { !issues.isEmpty }

    private(set) lazy var actions = ViewHierarchyAction.actions(for: self)

    private(set) lazy var isContainer: Bool = children.isEmpty == false

    private(set) lazy var deepestAbsoulteLevel: Int = children.map(\.depth).max() ?? depth

    private(set) lazy var children: [ViewHierarchyReference] = {
        rootView?.originalSubviews.map { .init($0, depth: depth + 1, iconProvider: iconProvider, parent: self) } ?? []
    }()

    // MARK: - Private Properties

    private let _className: String

    private let _classNameWithoutQualifiers: String

    private let _elementName: String

    var isCollapsed: Bool

    // MARK: - Computed Properties

    var iconImage: UIImage? {
        iconProvider(rootView)
    }

    var allParents: [ViewHierarchyReference] {
        var array = [ViewHierarchyReference]()

        if let parent = parent {
            array.append(parent)
            array.append(contentsOf: parent.allParents)
        }

        return array
    }

    var deepestRelativeLevel: Int {
        deepestAbsoulteLevel - depth
    }

    // MARK: - Init

    convenience init(_ rootView: UIView, iconProvider: @escaping IconProvider) {
        self.init(rootView, depth: .zero, isCollapsed: false, iconProvider: iconProvider, parent: nil)
    }

    init(_ rootView: UIView, depth: Int, isCollapsed: Bool = false, iconProvider: @escaping IconProvider, parent: ViewHierarchyReference?) {
        self.rootView = rootView

        self.depth = depth

        self.parent = parent

        self.iconProvider = iconProvider

        self.isCollapsed = isCollapsed

        identifier = ObjectIdentifier(rootView)

        canPresentOnTop = rootView.canPresentOnTop

        isUserInteractionEnabled = rootView.isUserInteractionEnabled

        _className = rootView.className

        _classNameWithoutQualifiers = rootView.classNameWithoutQualifiers

        _elementName = rootView.elementName

        isSystemView = rootView.isSystemView

        frame = rootView.frame

        accessibilityIdentifier = rootView.accessibilityIdentifier

        canHostInspectorView = rootView.canHostInspectorView
    }
}

// MARK: - ViewHierarchyProtocol {

extension ViewHierarchyReference: ViewHierarchyProtocol {
    var classNameWithoutQualifiers: String {
        guard let rootView = rootView else {
            return _classNameWithoutQualifiers
        }

        return rootView.classNameWithoutQualifiers
    }

    var constraintReferences: [NSLayoutConstraintInspectableViewModel] {
        rootView?.constraintReferences ?? []
    }

    var horizontalConstraintReferences: [NSLayoutConstraintInspectableViewModel] {
        rootView?.horizontalConstraintReferences ?? []
    }

    var verticalConstraintReferences: [NSLayoutConstraintInspectableViewModel] {
        rootView?.verticalConstraintReferences ?? []
    }

    var elementName: String {
        guard let rootView = rootView else {
            return _elementName
        }

        return rootView.elementName
    }

    var className: String {
        rootView?.className ?? _className
    }

    var displayName: String {
        guard let rootView = rootView else {
            return _elementName
        }

        return rootView.displayName
    }

    var flattenedSubviewReferences: [ViewHierarchyReference] {
        let array = children.flatMap { [$0] + $0.flattenedSubviewReferences }

        return array
    }

    var inspectableViewReferences: [ViewHierarchyReference] {
        let flattenedViewHierarchy = [self] + flattenedSubviewReferences

        let inspectableViews = flattenedViewHierarchy.filter(\.canHostInspectorView)

        return inspectableViews
    }
}

// MARK: - Hashable

extension ViewHierarchyReference: Hashable {
    static func == (lhs: ViewHierarchyReference, rhs: ViewHierarchyReference) -> Bool {
        lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(rootView)
    }
}

extension ViewHierarchyReference {
    var isHidingHighlightViews: Bool {
        guard let view = rootView else {
            return false
        }

        for view in view.allSubviews where view is LayerViewProtocol {
            if view.isHidden {
                return true
            }
        }

        return false
    }
}

extension ViewHierarchyReference: ViewHierarchyReferenceSummaryViewModelProtocol {
    var title: String {
        elementName
    }

    var titleFont: UIFont {
        ElementInspector.appearance.titleFont(forRelativeDepth: .zero)
    }

    var subtitle: String {
        elementDescription
    }

    var showCollapseButton: Bool {
        false
    }

    var isHidden: Bool {
        false
    }

    var relativeDepth: Int {
        .zero
    }

    var automaticallyAdjustIndentation: Bool {
        false
    }

}
