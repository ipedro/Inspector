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

extension ViewHierarchyElement {
    struct Snapshot: ViewHierarchyElementProtocol, ExpirableProtocol, Hashable {
        let expirationDate: Date = Date().addingTimeInterval(Inspector.configuration.snapshotExpirationTimeInterval)
        let depth: Int
        let displayName: String
        let classNameWithoutQualifiers: String
        let className: String
        let elementName: String
        let viewIdentifier: ObjectIdentifier
        let shortElementDescription: String
        let elementDescription: String
        let isUserInteractionEnabled: Bool
        let frame: CGRect
        let accessibilityIdentifier: String?
        let issues: [ViewHierarchyIssue]
        let iconImage: UIImage?
        let canHostInspectorView: Bool
        let isInternalView: Bool
        let canPresentOnTop: Bool
        let constraintElements: [LayoutConstraintElement]
        let isContainer: Bool

        init(view: UIView, icon: UIImage?, depth: Int) {
            self.depth = depth

            viewIdentifier = view.viewIdentifier
            isContainer = view.isContainer
            shortElementDescription = view.shortElementDescription
            elementDescription = view.elementDescription
            isUserInteractionEnabled = view.isUserInteractionEnabled
            frame = view.frame
            accessibilityIdentifier = view.accessibilityIdentifier
            issues = view.issues
            iconImage = icon
            canHostInspectorView = view.canHostInspectorView
            isInternalView = view._isInternalView
            className = view._className
            classNameWithoutQualifiers = view._classNameWithoutQualifiers
            elementName = view.elementName
            displayName = view.displayName
            canPresentOnTop = view.canPresentOnTop
            constraintElements = view.constraintElements
        }
    }
}

final class ViewHierarchyElement: NSObject {
    override var debugDescription: String {
        String(describing: latestSnapshot)
    }

    weak var rootView: UIView?

    var parent: ViewHierarchyElement?

    private let iconProvider: ViewHierarchyElementIconProvider

    let initialSnapshot: Snapshot

    private(set) lazy var history: [Snapshot] = [initialSnapshot]

    var isCollapsed: Bool

    var depth: Int {
        didSet {
            guard let view = rootView else {
                children = []
                return
            }

            children = view.originalSubviews.map {
                .init($0, iconProvider: iconProvider, depth: depth + 1, parent: self)
            }
        }
    }

    private(set) lazy var deepestAbsoulteLevel: Int = children.map(\.depth).max() ?? depth

    private(set) lazy var children: [ViewHierarchyElement] = rootView?.originalSubviews.map {
        .init($0, iconProvider: iconProvider, depth: depth + 1, parent: self)
    } ?? []

    private(set) lazy var allChildren: [ViewHierarchyElement] = children.flatMap { [$0] + $0.allChildren }

    // MARK: - Computed Properties

    var allParents: [ViewHierarchyElement] {
        var array = [ViewHierarchyElement]()

        if let parent = parent {
            array.append(parent)
            array.append(contentsOf: parent.allParents)
        }

        return array
    }

    var deepestRelativeLevel: Int {
        deepestAbsoulteLevel - depth
    }

    var latestSnapshot: Snapshot {
        history.last ?? initialSnapshot
    }

    var inspectableChildren: [ViewHierarchyElement] {
        let selfAndChildren = [self] + allChildren

        let inspectableViews = selfAndChildren.filter(\.canHostInspectorView)

        return inspectableViews
    }

    // MARK: - Init

    init(
        _ rootView: UIView,
        iconProvider: ViewHierarchyElementIconProvider,
        depth: Int = .zero,
        isCollapsed: Bool = false,
        parent: ViewHierarchyElement? = nil
    ) {
        self.rootView = rootView
        self.depth = depth
        self.parent = parent
        self.iconProvider = iconProvider
        self.isCollapsed = isCollapsed

        initialSnapshot = Snapshot(
            view: rootView,
            icon: iconProvider.value(for: rootView),
            depth: depth
        )
    }

    private func setNeedsSnapshot() {
        debounce(#selector(makeSnapshot), delay: Inspector.configuration.snapshotExpirationTimeInterval)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(makeSnapshot), object: nil)
        perform(#selector(makeSnapshot), with: nil, afterDelay: Inspector.configuration.snapshotExpirationTimeInterval)
    }

    @objc private func makeSnapshot() {
        guard let rootView = rootView else { return }

        let newSnapshot = Snapshot(view: rootView, icon: iconProvider.value(for: rootView), depth: depth)

        history.append(newSnapshot)
    }
}

// MARK: - ViewHierarchyElementProtocol {

extension ViewHierarchyElement: ViewHierarchyElementProtocol {
    // MARK: - Cached properties

    var iconImage: UIImage? {
        guard let rootView = rootView else {
            return latestSnapshot.iconImage
        }

        let currentIcon = iconProvider.value(for: rootView)

        if currentIcon?.pngData() != latestSnapshot.iconImage?.pngData() {
            setNeedsSnapshot()
        }

        return currentIcon
    }

    var isContainer: Bool {
        guard latestSnapshot.isExpired, let rootView = rootView else {
            return latestSnapshot.isContainer
        }

        if rootView.isContainer != latestSnapshot.isContainer {
            setNeedsSnapshot()
        }

        return rootView.isContainer
    }

    var shortElementDescription: String {
        guard latestSnapshot.isExpired, let rootView = rootView else {
            return latestSnapshot.shortElementDescription
        }

        if rootView.shortElementDescription != latestSnapshot.shortElementDescription {
            setNeedsSnapshot()
        }

        return rootView.shortElementDescription
    }

    var elementDescription: String {
        guard let rootView = rootView else {
            return latestSnapshot.elementDescription
        }

        if rootView.canHostInspectorView != latestSnapshot.canHostInspectorView {
            setNeedsSnapshot()
        }

        return rootView.elementDescription
    }

    var canHostInspectorView: Bool {
        guard latestSnapshot.isExpired, let rootView = rootView else {
            return latestSnapshot.canHostInspectorView
        }

        if rootView.canHostInspectorView != latestSnapshot.canHostInspectorView {
            setNeedsSnapshot()
        }

        return rootView.canHostInspectorView
    }

    var isInternalView: Bool {
        guard latestSnapshot.isExpired, let rootView = rootView else {
            return latestSnapshot.isInternalView
        }

        if rootView.isInternalView != latestSnapshot.isInternalView {
            setNeedsSnapshot()
        }

        return rootView.isInternalView
    }

    var elementName: String {
        guard latestSnapshot.isExpired, let rootView = rootView else {
            return latestSnapshot.elementName
        }

        if rootView.elementName != latestSnapshot.elementName {
            setNeedsSnapshot()
        }

        return rootView.elementName
    }

    var displayName: String {
        guard latestSnapshot.isExpired, let rootView = rootView else {
            return latestSnapshot.displayName
        }

        if rootView.displayName != latestSnapshot.displayName {
            setNeedsSnapshot()
        }

        return rootView.displayName
    }

    var frame: CGRect {
        guard latestSnapshot.isExpired, let rootView = rootView else {
            return latestSnapshot.frame
        }

        if rootView.frame != latestSnapshot.frame {
            setNeedsSnapshot()
        }

        return rootView.frame
    }

    var accessibilityIdentifier: String? {
        guard latestSnapshot.isExpired, let rootView = rootView else {
            return latestSnapshot.accessibilityIdentifier
        }

        if rootView.accessibilityIdentifier != latestSnapshot.accessibilityIdentifier {
            setNeedsSnapshot()
        }

        return rootView.accessibilityIdentifier
    }

    var constraintElements: [LayoutConstraintElement] {
        guard latestSnapshot.isExpired, let rootView = rootView else {
            return latestSnapshot.constraintElements
        }

        if rootView.constraintElements != latestSnapshot.constraintElements {
            setNeedsSnapshot()
        }

        return rootView.constraintElements
    }

    // MARK: - Live Properties
    var canPresentOnTop: Bool {
        initialSnapshot.canPresentOnTop
    }

    var className: String {
        initialSnapshot.className
    }

    var classNameWithoutQualifiers: String {
        initialSnapshot.classNameWithoutQualifiers
    }
    var isUserInteractionEnabled: Bool {
        initialSnapshot.isUserInteractionEnabled
    }

    var issues: [ViewHierarchyIssue] {
        guard let rootView = rootView else {
            var issues = latestSnapshot.issues
            issues.append(.lostConnection)

            return issues
        }

        if rootView.issues != latestSnapshot.issues {
            setNeedsSnapshot()
        }

        return rootView.issues
    }

    var viewIdentifier: ObjectIdentifier {
        initialSnapshot.viewIdentifier
    }
}

extension ViewHierarchyElement {
    var isShowingLayerWireframeView: Bool {
        rootView?.subviews.contains { $0 is WireframeView } == true
    }

    var isHostingAnyLayerHighlightView: Bool {
        rootView?.allSubviews.contains { $0 is HighlightView } == true
    }

    var containsVisibleHighlightViews: Bool {
        rootView?.allSubviews.contains { $0 is HighlightView && $0.isHidden == false } == true
    }
}
