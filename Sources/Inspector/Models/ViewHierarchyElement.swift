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
    struct Snapshot: ViewHierarchyElementProtocol, Hashable {
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
        let constraintReferences: [NSLayoutConstraintInspectableViewModel]
        let horizontalConstraintReferences: [NSLayoutConstraintInspectableViewModel]
        let verticalConstraintReferences: [NSLayoutConstraintInspectableViewModel]
        let depth: Int
        let isContainer: Bool
        let createdAt = Date()

        init(view: UIView, icon: UIImage?, depth: Int) {
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
            constraintReferences = view.constraintReferences
            horizontalConstraintReferences = view.horizontalConstraintReferences
            verticalConstraintReferences = view.verticalConstraintReferences
            self.depth = depth
        }
    }
}

final class ViewHierarchyElement: NSObject {
    override var debugDescription: String {
        String(describing: latestSnapshot)
    }

    typealias IconProvider = (UIView?) -> UIImage?

    weak var rootView: UIView?

    var parent: ViewHierarchyElement?

    private let iconProvider: IconProvider?

    let initialSnapshot: Snapshot

    private(set) lazy var history: [Snapshot] = [initialSnapshot] {
        didSet {
            print("Updated snapshot of \(initialSnapshot.elementName)")
            print("New total count is \(history.count)")
            print("---")

            guard history.count >= 2 else { return }

            var array = history
            let new = array.popLast()!
            let old = array.popLast()!

            let newComponents = String(describing: new).split(separator: ",")
            let oldComponents = String(describing: old).split(separator: ",")

            for (oldLine, newLine) in zip(oldComponents, newComponents) where oldLine != newLine {
                let oldDescription = oldLine.trimmingCharacters(in: .whitespacesAndNewlines)
                let newDescription = newLine.trimmingCharacters(in: .whitespacesAndNewlines)

                print("\(oldDescription) -> \(newDescription)")
            }
        }
    }

    var isCollapsed: Bool

    var depth: Int {
        didSet {
            guard let view = rootView else {
                children = []
                return
            }

            children = view.originalSubviews.map {
                .init($0, depth: depth + 1, iconProvider: iconProvider, parent: self)
            }
        }
    }

    private(set) lazy var deepestAbsoulteLevel: Int = children.map(\.depth).max() ?? depth

    private(set) lazy var children: [ViewHierarchyElement] = rootView?.originalSubviews.map {
        .init($0, depth: depth + 1, iconProvider: iconProvider, parent: self)
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

    var inspectableViewReferences: [ViewHierarchyElement] {
        let selfAndChildren = [self] + allChildren

        let inspectableViews = selfAndChildren.filter(\.canHostInspectorView)

        return inspectableViews
    }

    // MARK: - Init

    convenience init(_ rootView: UIView, iconProvider: IconProvider?) {
        self.init(rootView, depth: .zero, isCollapsed: false, iconProvider: iconProvider, parent: nil)
    }

    init(_ rootView: UIView, depth: Int, isCollapsed: Bool = false, iconProvider: IconProvider?, parent: ViewHierarchyElement?) {
        self.rootView = rootView
        self.depth = depth
        self.parent = parent
        self.iconProvider = iconProvider
        self.isCollapsed = isCollapsed

        initialSnapshot = Snapshot(
            view: rootView,
            icon: iconProvider?(rootView),
            depth: depth
        )
    }

    private func setNeedsSnapshot() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(makeSnapshot), object: nil)
        perform(#selector(makeSnapshot), with: nil, afterDelay: .long)
    }

    @objc private func makeSnapshot() {
        guard let rootView = rootView else { return }

        let newSnapshot = Snapshot(view: rootView, icon: iconProvider?(rootView), depth: depth)

        history.append(newSnapshot)
    }
}

// MARK: - ViewHierarchyElementProtocol {

extension ViewHierarchyElement: ViewHierarchyElementProtocol {
    var viewIdentifier: ObjectIdentifier {
        initialSnapshot.viewIdentifier
    }

    var iconImage: UIImage? {
        guard let rootView = rootView else {
            return latestSnapshot.iconImage
        }

        let currentIcon = iconProvider?(rootView)

        if currentIcon?.pngData() != latestSnapshot.iconImage?.pngData() {
            setNeedsSnapshot()
        }

        return currentIcon
    }

    var isContainer: Bool {
        guard let rootView = rootView else {
            return latestSnapshot.isContainer
        }

        if rootView.isContainer != latestSnapshot.isContainer {
            setNeedsSnapshot()
        }

        return rootView.isContainer
    }

    var shortElementDescription: String {
        guard let rootView = rootView else {
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
        guard let rootView = rootView else {
            return latestSnapshot.canHostInspectorView
        }

        if rootView.canHostInspectorView != latestSnapshot.canHostInspectorView {
            setNeedsSnapshot()
        }

        return rootView.canHostInspectorView
    }

    var isInternalView: Bool {
        guard let rootView = rootView else {
            return latestSnapshot.isInternalView
        }

        if rootView.isInternalView != latestSnapshot.isInternalView {
            setNeedsSnapshot()
        }

        return rootView.isInternalView
    }

    var className: String {
        guard let rootView = rootView else {
            return latestSnapshot.className
        }

        if rootView.className != latestSnapshot.className {
            setNeedsSnapshot()
        }

        return rootView.className
    }

    var classNameWithoutQualifiers: String {
        guard let rootView = rootView else {
            return latestSnapshot.classNameWithoutQualifiers
        }

        if rootView.classNameWithoutQualifiers != latestSnapshot.classNameWithoutQualifiers {
            setNeedsSnapshot()
        }

        return rootView.classNameWithoutQualifiers
    }

    var elementName: String {
        guard let rootView = rootView else {
            return latestSnapshot.elementName
        }

        if rootView.elementName != latestSnapshot.elementName {
            setNeedsSnapshot()
        }

        return rootView.elementName
    }

    var displayName: String {
        guard let rootView = rootView else {
            return latestSnapshot.displayName
        }

        if rootView.displayName != latestSnapshot.displayName {
            setNeedsSnapshot()
        }

        return rootView.displayName
    }

    var canPresentOnTop: Bool {
        guard let rootView = rootView else {
            return latestSnapshot.canPresentOnTop
        }

        if rootView.canPresentOnTop != latestSnapshot.canPresentOnTop {
            setNeedsSnapshot()
        }

        return rootView.canPresentOnTop
    }

    var isUserInteractionEnabled: Bool {
        initialSnapshot.isUserInteractionEnabled
    }

    var frame: CGRect {
        guard let rootView = rootView else {
            return latestSnapshot.frame
        }

        if rootView.frame != latestSnapshot.frame {
            setNeedsSnapshot()
        }

        return rootView.frame
    }

    var accessibilityIdentifier: String? {
        guard let rootView = rootView else {
            return latestSnapshot.accessibilityIdentifier
        }

        if rootView.accessibilityIdentifier != latestSnapshot.accessibilityIdentifier {
            setNeedsSnapshot()
        }

        return rootView.accessibilityIdentifier
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

    var constraintReferences: [NSLayoutConstraintInspectableViewModel] {
        guard let rootView = rootView else {
            return latestSnapshot.constraintReferences
        }

        if rootView.constraintReferences != latestSnapshot.constraintReferences {
            setNeedsSnapshot()
        }

        return rootView.constraintReferences
    }

    var horizontalConstraintReferences: [NSLayoutConstraintInspectableViewModel] {
        guard let rootView = rootView else {
            return latestSnapshot.horizontalConstraintReferences
        }

        if rootView.horizontalConstraintReferences != latestSnapshot.horizontalConstraintReferences {
            setNeedsSnapshot()
        }

        return rootView.horizontalConstraintReferences
    }

    var verticalConstraintReferences: [NSLayoutConstraintInspectableViewModel] {
        guard let rootView = rootView else {
            return latestSnapshot.verticalConstraintReferences
        }

        if rootView.verticalConstraintReferences != latestSnapshot.verticalConstraintReferences {
            setNeedsSnapshot()
        }

        return rootView.verticalConstraintReferences
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
