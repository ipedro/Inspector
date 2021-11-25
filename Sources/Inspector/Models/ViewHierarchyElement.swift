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

struct UIViewSnapshot: ExpirableProtocol {
    let identifier = UUID()
    let objectIdentifier: ObjectIdentifier
    let parent: ViewHierarchyElementReference? = nil
    var accessibilityIdentifier: String?
    var canHostInspectorView: Bool
    var canHostContextMenuInteraction: Bool
    var canPresentOnTop: Bool
    var className: String
    var classNameWithoutQualifiers: String
    var constraintElements: [LayoutConstraintElement]
    var depth: Int
    var displayName: String
    var elementDescription: String
    var elementName: String
    var expirationDate: Date = makeExpirationDate()
    var frame: CGRect
    var iconImage: UIImage?
    var isContainer: Bool
    var isHidden: Bool
    var isInternalType: Bool
    var isSystemContainer: Bool
    var isUserInteractionEnabled: Bool
    var issues: [ViewHierarchyIssue]
    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle
    var shortElementDescription: String
    var traitCollection: UITraitCollection

    init(view: UIView, icon: UIImage?, depth: Int) {
        accessibilityIdentifier = view.accessibilityIdentifier
        canHostContextMenuInteraction = view.canHostContextMenuInteraction
        canHostInspectorView = view.canHostInspectorView
        canPresentOnTop = view.canPresentOnTop
        className = view.className
        classNameWithoutQualifiers = view.classNameWithoutQualifiers
        constraintElements = view.constraintElements
        self.depth = depth
        displayName = view.displayName
        elementDescription = view.elementDescription
        elementName = view.elementName
        frame = view.frame
        iconImage = icon
        isContainer = view.isContainer
        isHidden = view.isHidden
        isInternalType = view.isInternalType
        isSystemContainer = view.isSystemContainer
        isUserInteractionEnabled = view.isUserInteractionEnabled
        issues = view.issues
        objectIdentifier = view.objectIdentifier
        overrideViewHierarchyInterfaceStyle = view.overrideViewHierarchyInterfaceStyle
        shortElementDescription = view.shortElementDescription
        traitCollection = view.traitCollection
    }

    private static func makeExpirationDate() -> Date {
        let expiration = Inspector.configuration.snapshotExpirationTimeInterval
        let expirationDate = Date().addingTimeInterval(expiration)

        return expirationDate
    }

    static func == (lhs: UIViewSnapshot, rhs: UIViewSnapshot) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

final class New_ViewHierarchyElement<Element: ViewHierarchyNodeRelationship & ExpirableProtocol> {
    let element: Element

    let iconProvider: ViewHierarchyElementIconProvider

    var depth: Int {
        didSet {
            // children.forEach { $0.depth = depth + 1 }
        }
    }

    private var store: SnapshotStore<Element>

    // MARK: - ViewHierarchyElementReference


    init(
        element: Element,
        iconProvider: ViewHierarchyElementIconProvider,
        depth: Int
    ) {
        self.element = element
        self.iconProvider = iconProvider
        self.depth = element.depth
        self.store = SnapshotStore(element: element)
    }
}

extension New_ViewHierarchyElement: ViewHierarchyElementReference {
    
}

final class ViewHierarchyElement {
    weak var underlyingView: UIView?

    weak var parent: ViewHierarchyElementReference?

    let iconProvider: ViewHierarchyElementIconProvider

    private var store: SnapshotStore<UIViewSnapshot>

    var isCollapsed: Bool

    var depth: Int {
        didSet {
            children.forEach { $0.depth = depth + 1 }
        }
    }

    lazy var children: [ViewHierarchyElementReference] = makeChildren()

    private(set) lazy var allChildren: [ViewHierarchyElementReference] = children.flatMap { [$0] + $0.allChildren }

    // MARK: - Computed Properties

    var deepestAbsoulteLevel: Int {
        children.map(\.depth).max() ?? depth
    }

    var deepestRelativeLevel: Int {
        deepestAbsoulteLevel - depth
    }

//    var viewHierarchy: [ViewHierarchyElementReference] {
//        let selfAndChildren = [self] + allChildren
//
//        let inspectableViews = selfAndChildren.filter(\.canHostInspectorView)
//
//        return inspectableViews
//    }

    // MARK: - Init

    init(
        with view: UIView,
        iconProvider: ViewHierarchyElementIconProvider,
        depth: Int = .zero,
        isCollapsed: Bool = false,
        parent: ViewHierarchyElementReference? = nil
    ) {
        self.underlyingView = view
        self.depth = depth
        self.parent = parent
        self.iconProvider = iconProvider
        self.isCollapsed = isCollapsed
        self.isUnderlyingViewUserInteractionEnabled = view.isUserInteractionEnabled

        let initialSnapshot = UIViewSnapshot(
            view: view,
            icon: iconProvider.resizedIcon(for: view),
            depth: depth
        )

        self.store = SnapshotStore(initialSnapshot)
    }

    var latestSnapshot: UIViewSnapshot { store.current }

    var isUnderlyingViewUserInteractionEnabled: Bool

    private func makeChildren() -> [ViewHierarchyElementReference] {
        underlyingView?.children.compactMap {
            ViewHierarchyElement(with: $0, iconProvider: iconProvider, depth: depth + 1, parent: self)
        } ?? []
    }
}

// MARK: - ViewHierarchyElementReference {

extension ViewHierarchyElement: ViewHierarchyElementReference {
    var canHostContextMenuInteraction: Bool {
        store.current.canHostContextMenuInteraction
    }

    var isSystemContainer: Bool {
        store.first.isSystemContainer
    }

    var underlyingObject: NSObject? {
        underlyingView
    }

    var underlyingViewController: UIViewController? { nil }

    var isHidden: Bool {
        get {
            underlyingView?.isHidden ?? false
        }
        set {
            underlyingView?.isHidden = newValue
        }
    }

    func hasChanges(inRelationTo identifier: UUID) -> Bool {
        latestSnapshotIdentifier != identifier
    }

    var latestSnapshotIdentifier: UUID {
        latestSnapshot.identifier
    }

    var isUserInteractionEnabled: Bool {
        isUnderlyingViewUserInteractionEnabled
    }

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.overrideViewHierarchyInterfaceStyle
        }

        if rootView.overrideViewHierarchyInterfaceStyle != store.current.overrideViewHierarchyInterfaceStyle {
            scheduleSnapshot()
        }

        return rootView.overrideViewHierarchyInterfaceStyle
    }

    var traitCollection: UITraitCollection {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.traitCollection
        }

        if rootView.traitCollection != store.current.traitCollection {
            scheduleSnapshot()
        }

        return rootView.traitCollection
    }

    // MARK: - Cached properties

    var iconImage: UIImage? {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.iconImage
        }

        let currentIcon = iconProvider.resizedIcon(for: rootView)

        if currentIcon?.pngData() != store.current.iconImage?.pngData() {
            scheduleSnapshot()
        }

        return currentIcon
    }

    var isContainer: Bool {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.isContainer
        }

        if rootView.isContainer != store.current.isContainer {
            scheduleSnapshot()
        }

        return rootView.isContainer
    }

    var shortElementDescription: String {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.shortElementDescription
        }

        if rootView.shortElementDescription != store.current.shortElementDescription {
            scheduleSnapshot()
        }

        return rootView.shortElementDescription
    }

    var elementDescription: String {
        guard let rootView = underlyingView else {
            return store.current.elementDescription
        }

        if rootView.canHostInspectorView != store.current.canHostInspectorView {
            scheduleSnapshot()
        }

        return rootView.elementDescription
    }

    var canHostInspectorView: Bool {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.canHostInspectorView
        }

        if rootView.canHostInspectorView != store.current.canHostInspectorView {
            scheduleSnapshot()
        }

        return rootView.canHostInspectorView
    }

    var isInternalType: Bool {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.isInternalType
        }

        if rootView.isInternalType != store.current.isInternalType {
            scheduleSnapshot()
        }

        return rootView.isInternalType
    }

    var elementName: String {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.elementName
        }

        if rootView.elementName != store.current.elementName {
            scheduleSnapshot()
        }

        return rootView.elementName
    }

    var displayName: String {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.displayName
        }

        if rootView.displayName != store.current.displayName {
            scheduleSnapshot()
        }

        return rootView.displayName
    }

    var frame: CGRect {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.frame
        }

        if rootView.frame != store.current.frame {
            scheduleSnapshot()
        }

        return rootView.frame
    }

    var accessibilityIdentifier: String? {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.accessibilityIdentifier
        }

        if rootView.accessibilityIdentifier != store.current.accessibilityIdentifier {
            scheduleSnapshot()
        }

        return rootView.accessibilityIdentifier
    }

    var constraintElements: [LayoutConstraintElement] {
        guard store.current.isExpired, let rootView = underlyingView else {
            return store.current.constraintElements
        }

        if rootView.constraintElements != store.current.constraintElements {
            scheduleSnapshot()
        }

        return rootView.constraintElements
    }

    enum SnapshotSchedulingError: Error {
        case dealocatedSelf, lostConnectionToView
    }

    private func scheduleSnapshot(_ handler: ((Result<UIViewSnapshot, SnapshotSchedulingError>) -> Void)? = nil) {
        store.scheduleSnapshot(
            .init(closure: { [weak self] in
                guard let self = self else {
                    handler?(.failure(.dealocatedSelf))
                    return nil
                }

                guard let rootView = self.underlyingView else {
                    handler?(.failure(.lostConnectionToView))
                    return nil
                }

                handler?(
                    .success(
                        .init(
                            view: rootView,
                            icon: self.iconProvider.resizedIcon(for: rootView),
                            depth: self.depth
                        )
                    )
                )
             }
          )
       )
    }

    // MARK: - Live Properties
    var canPresentOnTop: Bool {
        store.first.canPresentOnTop
    }

    var className: String {
        store.first.className
    }

    var classNameWithoutQualifiers: String {
        store.first.classNameWithoutQualifiers
    }

    var issues: [ViewHierarchyIssue] {
        guard let rootView = underlyingView else {
            var issues = store.current.issues
            issues.append(.lostConnection)

            return issues
        }

        if rootView.issues != store.current.issues {
            scheduleSnapshot()
        }

        return rootView.issues
    }

    var objectIdentifier: ObjectIdentifier {
        store.first.objectIdentifier
    }
}

// MARK: - Hashable

extension ViewHierarchyElement: Hashable {
    static func == (lhs: ViewHierarchyElement, rhs: ViewHierarchyElement) -> Bool {
        lhs.objectIdentifier == rhs.objectIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(objectIdentifier)
    }
}

private extension ViewHierarchyElementIconProvider {
    func resizedIcon(for view: UIView?) -> UIImage? {
        autoreleasepool {
            value(for: view)?.resized(.elementIconSize)
        }
    }
}
