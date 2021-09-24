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

    var depth: Int {
        didSet {
            guard let view = rootView else {
                children = []
                return
            }

            children = view.originalSubviews.map { .init($0, depth: depth + 1, parent: self) }
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
        rootView?.originalSubviews.map { .init($0, depth: depth + 1, parent: self) } ?? []
    }()

    // MARK: - Private Properties

    private let _className: String

    private let _classNameWithoutQualifiers: String

    private let _elementName: String

    // MARK: - Computed Properties

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

    convenience init(_ rootView: UIView) {
        self.init(rootView, depth: .zero, parent: nil)
    }

    init(_ rootView: UIView, depth: Int, parent: ViewHierarchyReference?) {
        self.rootView = rootView

        self.depth = depth

        self.parent = parent

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

// MARK: - Menu

@available(iOS 13.0, *)
extension ViewHierarchyReference {
    typealias MenuActionHandler = (ViewHierarchyReference, ViewHierarchyAction) -> Void
    
    func menu(includeActions: Bool = true, handler: @escaping MenuActionHandler) -> UIMenu? {
        var menus: [UIMenuElement] = []

        if includeActions, let actionsMenu = self.actionsMenu(options: .displayInline, handler: handler) {
            menus.append(actionsMenu)
        }

        let copyMenu = copyMenu(options: .displayInline)
        menus.append(copyMenu)

        if !children.isEmpty {
            if #available(iOS 14.0, *) {
                let childrenMenu = UIDeferredMenuElement { completion in
                    if let menu = self.childrenMenu(handler: handler) {
                        completion([menu])
                    }
                    else {
                        completion([])
                    }
                }
                menus.append(childrenMenu)
            }
            else if let childrenMenu = self.childrenMenu(handler: handler) {
                menus.append(childrenMenu)
            }
        }

        return UIMenu(
            title: elementName,
            image: nil,
            identifier: nil,
            children: menus
        )
    }

    private func childrenMenu(options: UIMenu.Options = .init(), handler: @escaping MenuActionHandler) -> UIMenu? {
        guard !children.isEmpty else { return nil }

        return UIMenu(
            title: Texts.children.appending(" (\(children.count))"),
            image: nil,
            identifier: nil,
            options: options,
            children: children.compactMap { $0.menu(handler: handler) }
        )
    }

    private func actionsMenu(options: UIMenu.Options = .init(), handler: @escaping MenuActionHandler) -> UIMenu? {
        guard !actions.isEmpty else { return nil }

        return UIMenu(
            title: Texts.open,
            options: options,
            children: actions.map { action in
                UIAction(title: Texts.open(action.title), image: action.image) { [weak self] _ in
                    guard let self = self else { return }
                    handler(self, action)
                }
            }
        )
    }

    private func copyMenu(options: UIMenu.Options = .init()) -> UIMenu {
        UIMenu(
            title: Texts.copy,
            image: .none,
            options: options,
            children: [
                UIAction.copyAction(
                    title: Texts.copy("Class Name"),
                    stringProvider: { [weak self] in self?.className }
                ),
                UIAction.copyAction(
                    title: Texts.copy("Description"),
                    stringProvider: { [weak self] in self?.elementDescription }
                )
            ]
        )
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
