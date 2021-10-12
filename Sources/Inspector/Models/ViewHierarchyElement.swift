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
    struct Snapshot: ViewHierarchyElementProtocol, ExpirableProtocol, Hashable {
        let identifier = UUID()
        let accessibilityIdentifier: String?
        let canHostInspectorView: Bool
        let canPresentOnTop: Bool
        let className: String
        let classNameWithoutQualifiers: String
        let constraintElements: [LayoutConstraintElement]
        let depth: Int
        let displayName: String
        let elementDescription: String
        let elementName: String
        let expirationDate: Date = Date().addingTimeInterval(Inspector.configuration.snapshotExpirationTimeInterval)
        let frame: CGRect
        let iconImage: UIImage?
        let isContainer: Bool
        let isInternalView: Bool
        let isUserInteractionEnabled: Bool
        let issues: [ViewHierarchyIssue]
        let overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle
        let shortElementDescription: String
        let traitCollection: UITraitCollection
        let viewIdentifier: ObjectIdentifier

        init(view: UIView, icon: UIImage?, depth: Int) {
            self.depth = depth

            accessibilityIdentifier = view.accessibilityIdentifier
            canHostInspectorView = view.canHostInspectorView
            canPresentOnTop = view.canPresentOnTop
            className = view._className
            classNameWithoutQualifiers = view._classNameWithoutQualifiers
            constraintElements = view.constraintElements
            displayName = view.displayName
            elementDescription = view.elementDescription
            elementName = view.elementName
            frame = view.frame
            iconImage = icon
            isContainer = view.isContainer
            isInternalView = view._isInternalView
            isUserInteractionEnabled = view.isUserInteractionEnabled
            issues = view.issues
            overrideViewHierarchyInterfaceStyle = view.overrideViewHierarchyInterfaceStyle
            shortElementDescription = view.shortElementDescription
            traitCollection = view.traitCollection
            viewIdentifier = view.viewIdentifier
        }
    }
}


final class ViewHierarchyElement: CustomDebugStringConvertible {
    var debugDescription: String {
        String(describing: store.latest)
    }

    weak var underlyingView: UIView?

    var viewController: ViewHierarchyController? {
        didSet {
            guard let viewController = viewController else { return }

            for childViewController in viewController.children {
                guard let underlyingViewController = childViewController.underlyingViewController, let view = underlyingViewController.viewIfLoaded else { continue }

                for childElement in allChildren where childElement.viewIdentifier == ObjectIdentifier(view) {
                    childElement.viewController = ViewHierarchyController(
                        with: underlyingViewController,
                        depth: depth + 1,
                        isCollapsed: childElement.isCollapsed,
                        parent: viewController
                    )
                }
            }
        }
    }

    weak var parent: ViewHierarchyElement?

    let iconProvider: ViewHierarchyElementIconProvider

    private var store: SnapshotStore<Snapshot>

    var isCollapsed: Bool

    var depth: Int {
        didSet {
            guard let view = underlyingView else {
                children = []
                return
            }

            children = view.originalSubviews.map {
                .init(with: $0, iconProvider: iconProvider, depth: depth + 1, parent: self)
            }
        }
    }

    private(set) lazy var deepestAbsoulteLevel: Int = children.map(\.depth).max() ?? depth

    private(set) lazy var children: [ViewHierarchyElement] = underlyingView?.originalSubviews.map {
        .init(with: $0, iconProvider: iconProvider, depth: depth + 1, parent: self)
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

    var inspectableChildren: [ViewHierarchyElement] {
        let selfAndChildren = [self] + allChildren

        let inspectableViews = selfAndChildren.filter(\.canHostInspectorView)

        return inspectableViews
    }

    // MARK: - Init

    init(
        with view: UIView,
        iconProvider: ViewHierarchyElementIconProvider,
        depth: Int = .zero,
        isCollapsed: Bool = false,
        parent: ViewHierarchyElement? = nil
    ) {
        self.underlyingView = view
        self.depth = depth
        self.parent = parent
        self.iconProvider = iconProvider
        self.isCollapsed = isCollapsed

        let initialSnapshot = Snapshot(
            view: view,
            icon: iconProvider.value(for: view),
            depth: depth
        )

        self.store = SnapshotStore(initialSnapshot)
    }

    var latestSnapshot: Snapshot { store.latest }
}

// MARK: - ViewHierarchyElementProtocol {

extension ViewHierarchyElement: ViewHierarchyElementProtocol {
    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.overrideViewHierarchyInterfaceStyle
        }

        if rootView.overrideViewHierarchyInterfaceStyle != store.latest.overrideViewHierarchyInterfaceStyle {
            scheduleSnapshot()
        }

        return rootView.overrideViewHierarchyInterfaceStyle
    }

    var traitCollection: UITraitCollection {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.traitCollection
        }

        if rootView.traitCollection != store.latest.traitCollection {
            scheduleSnapshot()
        }

        return rootView.traitCollection
    }

    // MARK: - Cached properties

    var iconImage: UIImage? {
        guard let rootView = underlyingView else {
            return store.latest.iconImage
        }

        let currentIcon = iconProvider.value(for: rootView)

        if currentIcon?.pngData() != store.latest.iconImage?.pngData() {
            scheduleSnapshot()
        }

        return currentIcon
    }

    var isContainer: Bool {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.isContainer
        }

        if rootView.isContainer != store.latest.isContainer {
            scheduleSnapshot()
        }

        return rootView.isContainer
    }

    var shortElementDescription: String {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.shortElementDescription
        }

        if rootView.shortElementDescription != store.latest.shortElementDescription {
            scheduleSnapshot()
        }

        return rootView.shortElementDescription
    }

    var elementDescription: String {
        guard let rootView = underlyingView else {
            return store.latest.elementDescription
        }

        if rootView.canHostInspectorView != store.latest.canHostInspectorView {
            scheduleSnapshot()
        }

        return rootView.elementDescription
    }

    var canHostInspectorView: Bool {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.canHostInspectorView
        }

        if rootView.canHostInspectorView != store.latest.canHostInspectorView {
            scheduleSnapshot()
        }

        return rootView.canHostInspectorView
    }

    var isInternalView: Bool {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.isInternalView
        }

        if rootView.isInternalView != store.latest.isInternalView {
            scheduleSnapshot()
        }

        return rootView.isInternalView
    }

    var elementName: String {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.elementName
        }

        if rootView.elementName != store.latest.elementName {
            scheduleSnapshot()
        }

        return rootView.elementName
    }

    var displayName: String {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.displayName
        }

        if rootView.displayName != store.latest.displayName {
            scheduleSnapshot()
        }

        return rootView.displayName
    }

    var frame: CGRect {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.frame
        }

        if rootView.frame != store.latest.frame {
            scheduleSnapshot()
        }

        return rootView.frame
    }

    var accessibilityIdentifier: String? {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.accessibilityIdentifier
        }

        if rootView.accessibilityIdentifier != store.latest.accessibilityIdentifier {
            scheduleSnapshot()
        }

        return rootView.accessibilityIdentifier
    }

    var constraintElements: [LayoutConstraintElement] {
        guard store.latest.isExpired, let rootView = underlyingView else {
            return store.latest.constraintElements
        }

        if rootView.constraintElements != store.latest.constraintElements {
            scheduleSnapshot()
        }

        return rootView.constraintElements
    }

    private func scheduleSnapshot() {
        store.scheduleSnapshot(
            .init(closure: { [weak self] in
                guard
                    let self = self,
                    let rootView = self.underlyingView
                else {
                    return nil
                }

                return Snapshot(view: rootView, icon: self.iconProvider.value(for: rootView), depth: self.depth)
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

    var isUserInteractionEnabled: Bool {
        store.first.isUserInteractionEnabled
    }

    var issues: [ViewHierarchyIssue] {
        guard let rootView = underlyingView else {
            var issues = store.latest.issues
            issues.append(.lostConnection)

            return issues
        }

        if rootView.issues != store.latest.issues {
            scheduleSnapshot()
        }

        return rootView.issues
    }

    var viewIdentifier: ObjectIdentifier {
        store.first.viewIdentifier
    }
}

// MARK: - Hashable

extension ViewHierarchyElement: Hashable {
    static func == (lhs: ViewHierarchyElement, rhs: ViewHierarchyElement) -> Bool {
        lhs.viewIdentifier == rhs.viewIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(viewIdentifier)
    }
}

extension ViewHierarchyElement {
    var isShowingLayerWireframeView: Bool {
        underlyingView?.subviews.contains { $0 is WireframeView } == true
    }

    var isHostingAnyLayerHighlightView: Bool {
        underlyingView?.allSubviews.contains { $0 is HighlightView } == true
    }

    var containsVisibleHighlightViews: Bool {
        underlyingView?.allSubviews.contains { $0 is HighlightView && $0.isHidden == false } == true
    }
}
