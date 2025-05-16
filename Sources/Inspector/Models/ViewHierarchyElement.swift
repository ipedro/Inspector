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
import UniformTypeIdentifiers

extension ViewHierarchyElement {
    struct Snapshot: ViewHierarchyElementRepresentable, ExpirableProtocol, Equatable {
        static func == (lhs: ViewHierarchyElement.Snapshot, rhs: ViewHierarchyElement.Snapshot) -> Bool {
            lhs.identifier == rhs.identifier
        }

        let identifier = UUID()
        let _objectIdentifier: ObjectIdentifier
        let parent: ViewHierarchyElementReference? = nil
        var accessibilityIdentifier: String?
        var _canHostInspectorView: Bool
        var _canHostContextMenuInteraction: Bool
        var _canPresentOnTop: Bool
        var _className: String
        var _classNameWithoutQualifiers: String
        var _constraintElements: [LayoutConstraintElement]
        var depth: Int
        var _displayName: String
        var _elementDescription: String
        var _elementName: String
        var expirationDate: Date = makeExpirationDate()
        var _frame: HashableBox<CGRect>
        var iconImage: UIImage?
        var isContainer: Bool
        var isHidden: Bool
        var _isInternalView: Bool
        var _isSystemContainer: Bool
        var isUserInteractionEnabled: Bool
        var _issues: [ViewHierarchyIssue]
        var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle
        var _shortElementDescription: String
        var traitCollection: UITraitCollection

        init(view: UIView, icon: UIImage?, depth: Int) {
            self.depth = depth

            accessibilityIdentifier = view.accessibilityIdentifier
            _canHostContextMenuInteraction = view._canHostContextMenuInteraction
            _canHostInspectorView = view._canHostInspectorView
            _canPresentOnTop = view._canPresentOnTop
            _className = view.__className
            _classNameWithoutQualifiers = view.__classNameWithoutQualifiers
            _constraintElements = view._constraintElements
            _displayName = view._displayName
            _elementDescription = view._elementDescription
            _elementName = view._elementName
            _frame = .init(wrappedValue: view.frame)
            iconImage = icon
            isContainer = !view.children.isEmpty
            isHidden = view.isHidden
            _isInternalView = view._isInternalView
            _isSystemContainer = view._isSystemContainer
            isUserInteractionEnabled = view.isUserInteractionEnabled
            _issues = view._issues
            _objectIdentifier = view._objectIdentifier
            overrideViewHierarchyInterfaceStyle = view.overrideViewHierarchyInterfaceStyle
            _shortElementDescription = view._shortElementDescription
            traitCollection = view.traitCollection
        }

        private static func makeExpirationDate() -> Date {
            let expiration = Inspector.sharedInstance.configuration.snapshotExpirationTimeInterval
            let expirationDate = Date().addingTimeInterval(expiration)

            return expirationDate
        }
    }
}

final class ViewHierarchyElement: CustomDebugStringConvertible {
    var debugDescription: String {
        String(describing: store.latest)
    }

    weak var _underlyingView: UIView?

    weak var parent: ViewHierarchyElementReference?

    let iconProvider: ViewHierarchyElementIconProvider?

    private var store: SnapshotStore<Snapshot>

    var isCollapsed: Bool

    var _depth: Int {
        didSet {
            children.forEach { $0._depth = _depth + 1 }
        }
    }

    lazy var children: [ViewHierarchyElementReference] = makeChildren()

    private(set) lazy var allChildren: [ViewHierarchyElementReference] = children.flatMap(\.viewHierarchy)

    // MARK: - Computed Properties

    var deepestAbsoulteLevel: Int {
        children.map(\._depth).max() ?? _depth
    }

    var deepestRelativeLevel: Int {
        deepestAbsoulteLevel - _depth
    }

    // MARK: - Init

    init(
        with view: UIView,
        iconProvider: ViewHierarchyElementIconProvider? = .none,
        depth: Int = .zero,
        isCollapsed: Bool = false,
        parent: ViewHierarchyElementReference? = .none
    ) {
        _underlyingView = view
        _depth = depth
        self.parent = parent
        self.iconProvider = iconProvider
        self.isCollapsed = isCollapsed
        isUnderlyingViewUserInteractionEnabled = view.isUserInteractionEnabled

        let initialSnapshot = Snapshot(
            view: view,
            icon: iconProvider?.resizedIcon(for: view),
            depth: depth
        )

        store = SnapshotStore(initialSnapshot)
    }

    var latestSnapshot: Snapshot { store.latest }

    var isUnderlyingViewUserInteractionEnabled: Bool

    private func makeChildren() -> [ViewHierarchyElementReference] {
        guard let underlyingView = _underlyingView else { return [] }
        return underlyingView
            .children
            .compactMap {
                ViewHierarchyElement(
                    with: $0,
                    iconProvider: iconProvider,
                    depth: _depth + 1,
                    parent: self
                )
            }
    }
}

// MARK: - ViewHierarchyElementReference {

extension ViewHierarchyElement: ViewHierarchyElementReference {
    var _canHostContextMenuInteraction: Bool {
        store.latest._canHostContextMenuInteraction
    }

    var _isSystemContainer: Bool {
        store.first._isSystemContainer
    }

    var _underlyingObject: NSObject? {
        _underlyingView
    }

    var underlyingViewController: UIViewController? { nil }

    var isHidden: Bool {
        get {
            _underlyingView?.isHidden ?? false
        }
        set {
            _underlyingView?.isHidden = newValue
        }
    }

    func hasChanges(inRelationTo identifier: UUID) -> Bool {
        _latestSnapshotIdentifier != identifier
    }

    var _latestSnapshotIdentifier: UUID {
        latestSnapshot.identifier
    }

    var isUserInteractionEnabled: Bool {
        isUnderlyingViewUserInteractionEnabled
    }

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest.overrideViewHierarchyInterfaceStyle
        }

        if rootView.overrideViewHierarchyInterfaceStyle != store.latest.overrideViewHierarchyInterfaceStyle {
            scheduleSnapshot()
        }

        return rootView.overrideViewHierarchyInterfaceStyle
    }

    var traitCollection: UITraitCollection {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest.traitCollection
        }

        if rootView.traitCollection != store.latest.traitCollection {
            scheduleSnapshot()
        }

        return rootView.traitCollection
    }

    var iconImage: UIImage? {
        iconProvider?.resizedIcon(for: _underlyingView)
    }

    // MARK: - Cached properties

    var cachedIconImage: UIImage? {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest.iconImage
        }

        let currentIcon = iconProvider?.resizedIcon(for: rootView)

        if currentIcon?.pngData() != store.latest.iconImage?.pngData() {
            scheduleSnapshot()
        }

        return currentIcon
    }

    var isContainer: Bool {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest.isContainer
        }

        if rootView.isContainer != store.latest.isContainer {
            scheduleSnapshot()
        }

        return rootView.isContainer
    }

    var _shortElementDescription: String {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest._shortElementDescription
        }

        if rootView._shortElementDescription != store.latest._shortElementDescription {
            scheduleSnapshot()
        }

        return rootView._shortElementDescription
    }

    var _elementDescription: String {
        guard let rootView = _underlyingView else {
            return store.latest._elementDescription
        }

        if rootView._canHostInspectorView != store.latest._canHostInspectorView {
            scheduleSnapshot()
        }

        return rootView._elementDescription
    }

    var _canHostInspectorView: Bool {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest._canHostInspectorView
        }

        if rootView._canHostInspectorView != store.latest._canHostInspectorView {
            scheduleSnapshot()
        }

        return rootView._canHostInspectorView
    }

    var _isInternalView: Bool {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest._isInternalView
        }

        if rootView._isInternalView != store.latest._isInternalView {
            scheduleSnapshot()
        }

        return rootView._isInternalView
    }

    var _elementName: String {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest._elementName
        }

        if rootView._elementName != store.latest._elementName {
            scheduleSnapshot()
        }

        return rootView._elementName
    }

    var _displayName: String {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest._displayName
        }

        if rootView._displayName != store.latest._displayName {
            scheduleSnapshot()
        }

        return rootView._displayName
    }

    var _frame: HashableBox<CGRect> {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest._frame
        }

        if rootView._frame != store.latest._frame {
            scheduleSnapshot()
        }

        return rootView._frame
    }

    var accessibilityIdentifier: String? {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest.accessibilityIdentifier
        }

        if rootView.accessibilityIdentifier != store.latest.accessibilityIdentifier {
            scheduleSnapshot()
        }

        return rootView.accessibilityIdentifier
    }

    var _constraintElements: [LayoutConstraintElement] {
        guard store.latest.isExpired, let rootView = _underlyingView else {
            return store.latest._constraintElements
        }

        if rootView._constraintElements != store.latest._constraintElements {
            scheduleSnapshot()
        }

        return rootView._constraintElements
    }

    enum SnapshotSchedulingError: Error {
        case dealocatedSelf, lostConnectionToView
    }

    private func scheduleSnapshot(_ handler: ((Result<Snapshot, SnapshotSchedulingError>) -> Void)? = nil) {
        store.scheduleSnapshot(
            .init(closure: { [weak self] in
                guard let self = self else {
                    handler?(.failure(.dealocatedSelf))
                    return nil
                }

                guard let rootView = self._underlyingView else {
                    handler?(.failure(.lostConnectionToView))
                    return nil
                }

                let snapshot = Snapshot(
                    view: rootView,
                    icon: self.iconProvider?.resizedIcon(for: rootView),
                    depth: self._depth
                )

                handler?(.success(snapshot))

                return snapshot
            }
            )
        )
    }

    // MARK: - Live Properties

    var _canPresentOnTop: Bool {
        store.first._canPresentOnTop
    }

    var _className: String {
        store.first._className
    }

    var _classNameWithoutQualifiers: String {
        store.first._classNameWithoutQualifiers
    }

    var _issues: [ViewHierarchyIssue] {
        guard let rootView = _underlyingView else {
            var issues = store.latest._issues
            issues.append(.lostConnection)

            return issues
        }

        if rootView._issues != store.latest._issues {
            scheduleSnapshot()
        }

        return rootView._issues
    }

    var _objectIdentifier: ObjectIdentifier {
        store.first._objectIdentifier
    }
}

// MARK: - Hashable

extension ViewHierarchyElement: Hashable {
    static func == (lhs: ViewHierarchyElement, rhs: ViewHierarchyElement) -> Bool {
        lhs._objectIdentifier == rhs._objectIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(_objectIdentifier)
    }
}

private extension ViewHierarchyElementIconProvider {
    func resizedIcon(for view: UIView?) -> UIImage? {
        autoreleasepool {
            value(for: view)?.resized(.elementIconSize)
        }
    }
}
