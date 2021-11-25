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

extension ViewHierarchyController {
    struct Snapshot: ViewHierarchyControllerProtocol, ExpirableProtocol, Hashable {
        let identifier = UUID()
        let depth: Int
        let title: String?
        var className: String
        var superclassName: String?
        var classNameWithoutQualifiers: String
        let expirationDate = Date().addingTimeInterval(Inspector.configuration.snapshotExpirationTimeInterval)

        let additionalSafeAreaInsets: UIEdgeInsets
        let definesPresentationContext: Bool
        let disablesAutomaticKeyboardDismissal: Bool
        let edgesForExtendedLayout: UIRectEdge
        let editButtonItem: UIBarButtonItem
        let extendedLayoutIncludesOpaqueBars: Bool
        let focusGroupIdentifier: String?
        let isBeingPresented: Bool
        let isEditing: Bool
        let isModalInPresentation: Bool
        let isSystemContainer: Bool
        let isViewLoaded: Bool
        let modalPresentationStyle: UIModalPresentationStyle
        let modalTransitionStyle: UIModalTransitionStyle
        let navigationItem: UINavigationItem
        let nibName: String?
        let overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle
        let performsActionsWhilePresentingModally: Bool
        let preferredContentSize: CGSize
        let preferredScreenEdgesDeferringSystemGestures: UIRectEdge
        let preferredStatusBarStyle: UIStatusBarStyle
        let preferredStatusBarUpdateAnimation: UIStatusBarAnimation
        let prefersHomeIndicatorAutoHidden: Bool
        let prefersPointerLocked: Bool
        let prefersStatusBarHidden: Bool
        let providesPresentationContextTransitionStyle: Bool
        let restorationClassName: String?
        let restorationIdentifier: String?
        let restoresFocusAfterTransition: Bool
        let shouldAutomaticallyForwardAppearanceMethods: Bool
        let systemMinimumLayoutMargins: NSDirectionalEdgeInsets
        let traitCollection: UITraitCollection
        let viewRespectsSystemMinimumLayoutMargins: Bool

        init(viewController: UIViewController, depth: Int) {
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = viewController.isModalInPresentation
                self.performsActionsWhilePresentingModally = viewController.performsActionsWhilePresentingModally
            } else {
                self.isModalInPresentation = false
                self.performsActionsWhilePresentingModally = false
            }

            if #available(iOS 14.0, *) {
                self.prefersPointerLocked = viewController.prefersPointerLocked
            } else {
                self.prefersPointerLocked = false
            }

            if #available(iOS 15.0, *) {
                self.focusGroupIdentifier = viewController.focusGroupIdentifier
            } else {
                self.focusGroupIdentifier = nil
            }

            if let restorationClass = viewController.restorationClass {
                self.restorationClassName = String(describing: restorationClass)
            } else {
                self.restorationClassName = nil
            }

            self.additionalSafeAreaInsets = viewController.additionalSafeAreaInsets
            self.className = viewController.className
            self.classNameWithoutQualifiers = viewController.classNameWithoutQualifiers
            self.definesPresentationContext = viewController.definesPresentationContext
            self.depth = depth
            self.disablesAutomaticKeyboardDismissal = viewController.disablesAutomaticKeyboardDismissal
            self.edgesForExtendedLayout = viewController.edgesForExtendedLayout
            self.editButtonItem = viewController.editButtonItem
            self.extendedLayoutIncludesOpaqueBars = viewController.extendedLayoutIncludesOpaqueBars
            self.isBeingPresented = viewController.isBeingPresented
            self.isEditing = viewController.isEditing
            self.isSystemContainer = viewController.isSystemContainer
            self.isViewLoaded = viewController.isViewLoaded
            self.modalPresentationStyle = viewController.modalPresentationStyle
            self.modalTransitionStyle = viewController.modalTransitionStyle
            self.navigationItem = viewController.navigationItem
            self.nibName = viewController.nibName
            self.overrideViewHierarchyInterfaceStyle = viewController.overrideViewHierarchyInterfaceStyle
            self.preferredContentSize = viewController.preferredContentSize
            self.preferredScreenEdgesDeferringSystemGestures = viewController.preferredScreenEdgesDeferringSystemGestures
            self.preferredStatusBarStyle = viewController.preferredStatusBarStyle
            self.preferredStatusBarUpdateAnimation = viewController.preferredStatusBarUpdateAnimation
            self.prefersHomeIndicatorAutoHidden = viewController.prefersHomeIndicatorAutoHidden
            self.prefersStatusBarHidden = viewController.prefersStatusBarHidden
            self.providesPresentationContextTransitionStyle = viewController.providesPresentationContextTransitionStyle
            self.restorationIdentifier = viewController.restorationIdentifier
            self.restoresFocusAfterTransition = viewController.restoresFocusAfterTransition
            self.shouldAutomaticallyForwardAppearanceMethods = viewController.shouldAutomaticallyForwardAppearanceMethods
            self.superclassName = viewController.superclassName
            self.systemMinimumLayoutMargins = viewController.systemMinimumLayoutMargins
            self.title = viewController.title
            self.traitCollection = viewController.traitCollection
            self.viewRespectsSystemMinimumLayoutMargins = viewController.viewRespectsSystemMinimumLayoutMargins
        }
    }
}

final class ViewHierarchyController: CustomDebugStringConvertible {
    var debugDescription: String {
        String(describing: store.current)
    }

    private(set) lazy var iconImage = iconProvider.value(for: underlyingViewController)

    let iconProvider: ViewHierarchyElementIconProvider

    weak var underlyingViewController: UIViewController?

    weak var parent: ViewHierarchyElementReference?

    private var store: SnapshotStore<Snapshot>

    var isCollapsed: Bool
    
    var depth: Int {
        didSet {
            children.forEach { $0.depth = depth + 1 }
        }
    }

    var rootElement: ViewHierarchyElementReference

    private(set) lazy var deepestAbsoulteLevel: Int = children.map(\.depth).max() ?? depth

    lazy var children: [ViewHierarchyElementReference] = makeChildren()

    private(set) lazy var allChildren: [ViewHierarchyElementReference] = children.flatMap { [$0] + $0.allChildren }

    // MARK: - Computed Properties

    var allParents: [ViewHierarchyElementReference] {
        var array = [ViewHierarchyElementReference]()

        if let parent = parent {
            array.append(parent)
            array.append(contentsOf: parent.allParents)
        }

        return array
    }

    var deepestRelativeLevel: Int {
        deepestAbsoulteLevel - depth
    }

    let objectIdentifier: ObjectIdentifier

    // MARK: - Init

    init(
        with viewController: UIViewController,
        iconProvider: ViewHierarchyElementIconProvider,
        depth: Int,
        isCollapsed: Bool,
        parent: ViewHierarchyController? = nil
    ) {
        self.objectIdentifier = ObjectIdentifier(viewController)
        self.isCollapsed = isCollapsed
        self.underlyingViewController = viewController
        self.depth = depth
        self.parent = parent
        self.iconProvider = iconProvider
        self.rootElement = ViewHierarchyElement(
            with: viewController.view,
            iconProvider: iconProvider,
            depth: depth,
            isCollapsed: isCollapsed,
            parent: parent?.rootElement
       )

        let initialSnapshot = Snapshot(
            viewController: viewController,
            depth: depth
        )

        self.store = SnapshotStore(initialSnapshot)
    }

    private func makeChildReference(from childViewController: UIViewController) -> ViewHierarchyController {
        ViewHierarchyController(
            with: childViewController,
            iconProvider: iconProvider,
            depth: depth + 1,
            isCollapsed: isCollapsed,
            parent: self
        )
    }

    private func makeChildren() -> [ViewHierarchyElementReference] {
        underlyingViewController?.children.compactMap { makeChildReference(from: $0) } ?? []
    }

    private func scheduleSnapshot() {
        store.scheduleSnapshot(
            .init(closure: { [weak self] in
                guard
                    let self = self,
                    let rootViewController = self.underlyingViewController
                else {
                    return nil
                }

                return Snapshot(
                    viewController: rootViewController,
                    depth: self.depth
                )
            })
        )
    }
}

extension ViewHierarchyController: ViewHierarchyElementReference {
    var canHostContextMenuInteraction: Bool {
        rootElement.canHostContextMenuInteraction
    }

    var isSystemContainer: Bool {
        store.first.isSystemContainer
    }

    var underlyingView: UIView? {
        underlyingViewController?.view
    }

    var underlyingObject: NSObject? {
        underlyingViewController
    }

    func hasChanges(inRelationTo identifier: UUID) -> Bool {
        latestSnapshotIdentifier != identifier
    }

    var latestSnapshotIdentifier: UUID {
        store.current.identifier
    }

    var canHostInspectorView: Bool {
        rootElement.canHostInspectorView
    }

    var isInternalType: Bool {
        rootElement.isInternalType
    }

    var elementName: String {
        className
    }

    var displayName: String {
        title ?? classNameWithoutQualifiers
    }

    var canPresentOnTop: Bool {
        rootElement.canPresentOnTop
    }

    var isUserInteractionEnabled: Bool {
        rootElement.isUserInteractionEnabled
    }

    var frame: CGRect {
        rootElement.frame
    }

    var accessibilityIdentifier: String? { nil }

    var issues: [ViewHierarchyIssue] {
        rootElement.issues
    }

    var constraintElements: [LayoutConstraintElement] {
        rootElement.constraintElements
    }


    var shortElementDescription: String {
        elementDescription
    }

    var elementDescription: String {
        [
            className,
            superclassName,
            "\(underlyingView?.allChildren.count ?? .zero) Subviews"
        ]
        .compactMap { $0 }
        .joined(separator: .newLine)
    }

    var isHidden: Bool {
        get { rootElement.isHidden }
        set { rootElement.isHidden = newValue }
    }
}

extension ViewHierarchyController: ViewHierarchyControllerProtocol {
    var className: String {
        return store.first.className
    }

    var superclassName: String? {
        return store.first.superclassName
    }

    var classNameWithoutQualifiers: String {
        return store.first.classNameWithoutQualifiers
    }

    var additionalSafeAreaInsets: UIEdgeInsets {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.additionalSafeAreaInsets
        }

        if viewController.additionalSafeAreaInsets != store.current.additionalSafeAreaInsets {
            scheduleSnapshot()
        }

        return viewController.additionalSafeAreaInsets
    }

    var definesPresentationContext: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.definesPresentationContext
        }

        if viewController.definesPresentationContext != store.current.definesPresentationContext {
            scheduleSnapshot()
        }

        return viewController.definesPresentationContext
    }

    var disablesAutomaticKeyboardDismissal: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.disablesAutomaticKeyboardDismissal
        }

        if viewController.disablesAutomaticKeyboardDismissal != store.current.disablesAutomaticKeyboardDismissal {
            scheduleSnapshot()
        }

        return viewController.disablesAutomaticKeyboardDismissal
    }

    var edgesForExtendedLayout: UIRectEdge {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.edgesForExtendedLayout
        }

        if viewController.edgesForExtendedLayout != store.current.edgesForExtendedLayout {
            scheduleSnapshot()
        }

        return viewController.edgesForExtendedLayout
    }

    var editButtonItem: UIBarButtonItem {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.editButtonItem
        }

        if viewController.editButtonItem != store.current.editButtonItem {
            scheduleSnapshot()
        }

        return viewController.editButtonItem
    }

    var extendedLayoutIncludesOpaqueBars: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.extendedLayoutIncludesOpaqueBars
        }

        if viewController.extendedLayoutIncludesOpaqueBars != store.current.extendedLayoutIncludesOpaqueBars {
            scheduleSnapshot()
        }

        return viewController.extendedLayoutIncludesOpaqueBars
    }

    var focusGroupIdentifier: String? {
        guard
            #available(iOS 15.0, *),
            store.current.isExpired,
            let viewController = underlyingViewController
        else {
            return store.current.focusGroupIdentifier
        }

        if viewController.focusGroupIdentifier != store.current.focusGroupIdentifier {
            scheduleSnapshot()
        }

        return viewController.focusGroupIdentifier
    }

    var isBeingPresented: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.isBeingPresented
        }

        if viewController.isBeingPresented != store.current.isBeingPresented {
            scheduleSnapshot()
        }

        return viewController.isBeingPresented
    }

    var isEditing: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.isEditing
        }

        if viewController.isEditing != store.current.isEditing {
            scheduleSnapshot()
        }

        return viewController.isEditing
    }

    var isModalInPresentation: Bool {
        guard
            #available(iOS 13.0, *),
            store.current.isExpired,
            let viewController = underlyingViewController
        else {
            return store.current.isModalInPresentation
        }

        if viewController.isModalInPresentation != store.current.isModalInPresentation {
            scheduleSnapshot()
        }

        return viewController.isModalInPresentation
    }

    var isViewLoaded: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.isViewLoaded
        }

        if viewController.isViewLoaded != store.current.isViewLoaded {
            scheduleSnapshot()
        }

        return viewController.isViewLoaded
    }

    var modalPresentationStyle: UIModalPresentationStyle {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.modalPresentationStyle
        }

        if viewController.modalPresentationStyle != store.current.modalPresentationStyle {
            scheduleSnapshot()
        }

        return viewController.modalPresentationStyle
    }

    var modalTransitionStyle: UIModalTransitionStyle {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.modalTransitionStyle
        }

        if viewController.modalTransitionStyle != store.current.modalTransitionStyle {
            scheduleSnapshot()
        }

        return viewController.modalTransitionStyle
    }

    var navigationItem: UINavigationItem {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.navigationItem
        }

        if viewController.navigationItem != store.current.navigationItem {
            scheduleSnapshot()
        }

        return viewController.navigationItem
    }

    var nibName: String? {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.nibName
        }

        if viewController.nibName != store.current.nibName {
            scheduleSnapshot()
        }

        return viewController.nibName
    }

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.overrideViewHierarchyInterfaceStyle
        }

        if viewController.overrideViewHierarchyInterfaceStyle != store.current.overrideViewHierarchyInterfaceStyle {
            scheduleSnapshot()
        }

        return viewController.overrideViewHierarchyInterfaceStyle
    }

    var traitCollection: UITraitCollection {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.traitCollection
        }

        if viewController.traitCollection != store.current.traitCollection {
            scheduleSnapshot()
        }

        return viewController.traitCollection
    }

    var performsActionsWhilePresentingModally: Bool {
        guard
            #available(iOS 13.0, *),
            store.current.isExpired,
            let viewController = underlyingViewController
        else {
            return store.current.performsActionsWhilePresentingModally
        }

        if viewController.performsActionsWhilePresentingModally != store.current.performsActionsWhilePresentingModally {
            scheduleSnapshot()
        }

        return viewController.performsActionsWhilePresentingModally
    }

    var preferredContentSize: CGSize {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.preferredContentSize
        }

        if viewController.preferredContentSize != store.current.preferredContentSize {
            scheduleSnapshot()
        }

        return viewController.preferredContentSize
    }

    var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.preferredScreenEdgesDeferringSystemGestures
        }

        if viewController.preferredScreenEdgesDeferringSystemGestures != store.current.preferredScreenEdgesDeferringSystemGestures {
            scheduleSnapshot()
        }

        return viewController.preferredScreenEdgesDeferringSystemGestures
    }

    var preferredStatusBarStyle: UIStatusBarStyle {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.preferredStatusBarStyle
        }

        if viewController.preferredStatusBarStyle != store.current.preferredStatusBarStyle {
            scheduleSnapshot()
        }

        return viewController.preferredStatusBarStyle
    }

    var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.preferredStatusBarUpdateAnimation
        }

        if viewController.preferredStatusBarUpdateAnimation != store.current.preferredStatusBarUpdateAnimation {
            scheduleSnapshot()
        }

        return viewController.preferredStatusBarUpdateAnimation
    }

    var prefersHomeIndicatorAutoHidden: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.prefersHomeIndicatorAutoHidden
        }

        if viewController.prefersHomeIndicatorAutoHidden != store.current.prefersHomeIndicatorAutoHidden {
            scheduleSnapshot()
        }

        return viewController.prefersHomeIndicatorAutoHidden
    }

    var prefersPointerLocked: Bool {
        guard
            #available(iOS 14.0, *),
            store.current.isExpired,
            let viewController = underlyingViewController
        else {
            return store.current.prefersPointerLocked
        }

        if viewController.prefersPointerLocked != store.current.prefersPointerLocked {
            scheduleSnapshot()
        }

        return viewController.prefersPointerLocked
    }

    var prefersStatusBarHidden: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.prefersStatusBarHidden
        }

        if viewController.prefersStatusBarHidden != store.current.prefersStatusBarHidden {
            scheduleSnapshot()
        }

        return viewController.prefersStatusBarHidden
    }

    var providesPresentationContextTransitionStyle: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.providesPresentationContextTransitionStyle
        }

        if viewController.providesPresentationContextTransitionStyle != store.current.providesPresentationContextTransitionStyle {
            scheduleSnapshot()
        }

        return viewController.providesPresentationContextTransitionStyle
    }

    var restorationClassName: String? {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.restorationClassName
        }

        if viewController.restorationClassName != store.current.restorationClassName {
            scheduleSnapshot()
        }

        return viewController.restorationClassName
    }

    var restorationIdentifier: String? {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.restorationIdentifier
        }

        if viewController.restorationIdentifier != store.current.restorationIdentifier {
            scheduleSnapshot()
        }

        return viewController.restorationIdentifier
    }

    var restoresFocusAfterTransition: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.restoresFocusAfterTransition
        }

        if viewController.restoresFocusAfterTransition != store.current.restoresFocusAfterTransition {
            scheduleSnapshot()
        }

        return viewController.restoresFocusAfterTransition
    }

    var shouldAutomaticallyForwardAppearanceMethods: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.shouldAutomaticallyForwardAppearanceMethods
        }

        if viewController.shouldAutomaticallyForwardAppearanceMethods != store.current.shouldAutomaticallyForwardAppearanceMethods {
            scheduleSnapshot()
        }

        return viewController.shouldAutomaticallyForwardAppearanceMethods
    }

    var systemMinimumLayoutMargins: NSDirectionalEdgeInsets {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.systemMinimumLayoutMargins
        }

        if viewController.systemMinimumLayoutMargins != store.current.systemMinimumLayoutMargins {
            scheduleSnapshot()
        }

        return viewController.systemMinimumLayoutMargins
    }

    var title: String? {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.title
        }

        if viewController.title != store.current.title {
            scheduleSnapshot()
        }

        return viewController.title
    }

    var viewRespectsSystemMinimumLayoutMargins: Bool {
        guard store.current.isExpired, let viewController = underlyingViewController else {
            return store.current.viewRespectsSystemMinimumLayoutMargins
        }

        if viewController.viewRespectsSystemMinimumLayoutMargins != store.current.viewRespectsSystemMinimumLayoutMargins {
            scheduleSnapshot()
        }

        return viewController.viewRespectsSystemMinimumLayoutMargins
    }
}

private extension UIViewController {
    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        if #available(iOS 13.0, *) {
            return .init(rawValue: overrideUserInterfaceStyle) ?? .unspecified
        }
        return .unspecified
    }

    var restorationClassName: String? {
        guard let restorationClass = restorationClass else { return nil }

        return String(describing: restorationClass)
    }
}
