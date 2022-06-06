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

extension UIEdgeInsets: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }
}

extension UIRectEdge: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }
}

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }
}

extension NSDirectionalEdgeInsets: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }
}

extension ViewHierarchyController {
    struct Snapshot: ViewHierarchyControllerProtocol, ExpirableProtocol, Hashable {
        let identifier = UUID()
        let depth: Int
        let title: String?
        var className: String
        var superclassName: String?
        var classNameWithoutQualifiers: String
        let expirationDate = Date().addingTimeInterval(Inspector.sharedInstance.configuration.snapshotExpirationTimeInterval)

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
            self.isModalInPresentation = viewController.isModalInPresentation
            self.performsActionsWhilePresentingModally = viewController.performsActionsWhilePresentingModally

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
            self.className = viewController._className
            self.classNameWithoutQualifiers = viewController._classNameWithoutQualifiers
            self.definesPresentationContext = viewController.definesPresentationContext
            self.depth = depth
            self.disablesAutomaticKeyboardDismissal = viewController.disablesAutomaticKeyboardDismissal
            self.edgesForExtendedLayout = viewController.edgesForExtendedLayout
            self.editButtonItem = viewController.editButtonItem
            self.extendedLayoutIncludesOpaqueBars = viewController.extendedLayoutIncludesOpaqueBars
            self.isBeingPresented = viewController.isBeingPresented
            self.isEditing = viewController.isEditing
            self.isSystemContainer = viewController._isSystemContainer
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
            self.superclassName = viewController._superclassName
            self.systemMinimumLayoutMargins = viewController.systemMinimumLayoutMargins
            self.title = viewController.title
            self.traitCollection = viewController.traitCollection
            self.viewRespectsSystemMinimumLayoutMargins = viewController.viewRespectsSystemMinimumLayoutMargins
        }
    }
}

final class ViewHierarchyController: CustomDebugStringConvertible {
    var debugDescription: String {
        String(describing: store.latest)
    }

    var iconImage: UIImage? {
        underlyingViewController?.tabBarItem.image ?? iconProvider?.value(for: underlyingViewController)
    }

    let iconProvider: ViewHierarchyElementIconProvider?

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

    var allChildren: [ViewHierarchyElementReference] {
        children.reversed().flatMap { [$0] + $0.allChildren }
    }

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
        _ viewController: UIViewController,
        iconProvider: ViewHierarchyElementIconProvider? = .none,
        depth: Int = .zero,
        isCollapsed: Bool = false,
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
            childViewController,
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
        underlyingViewController?.viewIfLoaded
    }

    var underlyingObject: NSObject? {
        underlyingViewController
    }

    func hasChanges(inRelationTo identifier: UUID) -> Bool {
        latestSnapshotIdentifier != identifier
    }

    var latestSnapshotIdentifier: UUID {
        store.latest.identifier
    }

    var canHostInspectorView: Bool { false }

    var isInternalView: Bool {
        rootElement.isInternalView
    }

    var elementName: String {
        className
    }

    var displayName: String {
        classNameWithoutQualifiers
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
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.additionalSafeAreaInsets
        }

        if viewController.additionalSafeAreaInsets != store.latest.additionalSafeAreaInsets {
            scheduleSnapshot()
        }

        return viewController.additionalSafeAreaInsets
    }

    var definesPresentationContext: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.definesPresentationContext
        }

        if viewController.definesPresentationContext != store.latest.definesPresentationContext {
            scheduleSnapshot()
        }

        return viewController.definesPresentationContext
    }

    var disablesAutomaticKeyboardDismissal: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.disablesAutomaticKeyboardDismissal
        }

        if viewController.disablesAutomaticKeyboardDismissal != store.latest.disablesAutomaticKeyboardDismissal {
            scheduleSnapshot()
        }

        return viewController.disablesAutomaticKeyboardDismissal
    }

    var edgesForExtendedLayout: UIRectEdge {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.edgesForExtendedLayout
        }

        if viewController.edgesForExtendedLayout != store.latest.edgesForExtendedLayout {
            scheduleSnapshot()
        }

        return viewController.edgesForExtendedLayout
    }

    var editButtonItem: UIBarButtonItem {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.editButtonItem
        }

        if viewController.editButtonItem != store.latest.editButtonItem {
            scheduleSnapshot()
        }

        return viewController.editButtonItem
    }

    var extendedLayoutIncludesOpaqueBars: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.extendedLayoutIncludesOpaqueBars
        }

        if viewController.extendedLayoutIncludesOpaqueBars != store.latest.extendedLayoutIncludesOpaqueBars {
            scheduleSnapshot()
        }

        return viewController.extendedLayoutIncludesOpaqueBars
    }

    var focusGroupIdentifier: String? {
        guard
            #available(iOS 15.0, *),
            store.latest.isExpired,
            let viewController = underlyingViewController
        else {
            return store.latest.focusGroupIdentifier
        }

        if viewController.focusGroupIdentifier != store.latest.focusGroupIdentifier {
            scheduleSnapshot()
        }

        return viewController.focusGroupIdentifier
    }

    var isBeingPresented: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.isBeingPresented
        }

        if viewController.isBeingPresented != store.latest.isBeingPresented {
            scheduleSnapshot()
        }

        return viewController.isBeingPresented
    }

    var isEditing: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.isEditing
        }

        if viewController.isEditing != store.latest.isEditing {
            scheduleSnapshot()
        }

        return viewController.isEditing
    }

    var isModalInPresentation: Bool {
        guard
            #available(iOS 13.0, *),
            store.latest.isExpired,
            let viewController = underlyingViewController
        else {
            return store.latest.isModalInPresentation
        }

        if viewController.isModalInPresentation != store.latest.isModalInPresentation {
            scheduleSnapshot()
        }

        return viewController.isModalInPresentation
    }

    var isViewLoaded: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.isViewLoaded
        }

        if viewController.isViewLoaded != store.latest.isViewLoaded {
            scheduleSnapshot()
        }

        return viewController.isViewLoaded
    }

    var modalPresentationStyle: UIModalPresentationStyle {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.modalPresentationStyle
        }

        if viewController.modalPresentationStyle != store.latest.modalPresentationStyle {
            scheduleSnapshot()
        }

        return viewController.modalPresentationStyle
    }

    var modalTransitionStyle: UIModalTransitionStyle {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.modalTransitionStyle
        }

        if viewController.modalTransitionStyle != store.latest.modalTransitionStyle {
            scheduleSnapshot()
        }

        return viewController.modalTransitionStyle
    }

    var navigationItem: UINavigationItem {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.navigationItem
        }

        if viewController.navigationItem != store.latest.navigationItem {
            scheduleSnapshot()
        }

        return viewController.navigationItem
    }

    var nibName: String? {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.nibName
        }

        if viewController.nibName != store.latest.nibName {
            scheduleSnapshot()
        }

        return viewController.nibName
    }

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.overrideViewHierarchyInterfaceStyle
        }

        if viewController.overrideViewHierarchyInterfaceStyle != store.latest.overrideViewHierarchyInterfaceStyle {
            scheduleSnapshot()
        }

        return viewController.overrideViewHierarchyInterfaceStyle
    }

    var traitCollection: UITraitCollection {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.traitCollection
        }

        if viewController.traitCollection != store.latest.traitCollection {
            scheduleSnapshot()
        }

        return viewController.traitCollection
    }

    var performsActionsWhilePresentingModally: Bool {
        guard
            #available(iOS 13.0, *),
            store.latest.isExpired,
            let viewController = underlyingViewController
        else {
            return store.latest.performsActionsWhilePresentingModally
        }

        if viewController.performsActionsWhilePresentingModally != store.latest.performsActionsWhilePresentingModally {
            scheduleSnapshot()
        }

        return viewController.performsActionsWhilePresentingModally
    }

    var preferredContentSize: CGSize {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.preferredContentSize
        }

        if viewController.preferredContentSize != store.latest.preferredContentSize {
            scheduleSnapshot()
        }

        return viewController.preferredContentSize
    }

    var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.preferredScreenEdgesDeferringSystemGestures
        }

        if viewController.preferredScreenEdgesDeferringSystemGestures != store.latest.preferredScreenEdgesDeferringSystemGestures {
            scheduleSnapshot()
        }

        return viewController.preferredScreenEdgesDeferringSystemGestures
    }

    var preferredStatusBarStyle: UIStatusBarStyle {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.preferredStatusBarStyle
        }

        if viewController.preferredStatusBarStyle != store.latest.preferredStatusBarStyle {
            scheduleSnapshot()
        }

        return viewController.preferredStatusBarStyle
    }

    var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.preferredStatusBarUpdateAnimation
        }

        if viewController.preferredStatusBarUpdateAnimation != store.latest.preferredStatusBarUpdateAnimation {
            scheduleSnapshot()
        }

        return viewController.preferredStatusBarUpdateAnimation
    }

    var prefersHomeIndicatorAutoHidden: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.prefersHomeIndicatorAutoHidden
        }

        if viewController.prefersHomeIndicatorAutoHidden != store.latest.prefersHomeIndicatorAutoHidden {
            scheduleSnapshot()
        }

        return viewController.prefersHomeIndicatorAutoHidden
    }

    var prefersPointerLocked: Bool {
        guard
            #available(iOS 14.0, *),
            store.latest.isExpired,
            let viewController = underlyingViewController
        else {
            return store.latest.prefersPointerLocked
        }

        if viewController.prefersPointerLocked != store.latest.prefersPointerLocked {
            scheduleSnapshot()
        }

        return viewController.prefersPointerLocked
    }

    var prefersStatusBarHidden: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.prefersStatusBarHidden
        }

        if viewController.prefersStatusBarHidden != store.latest.prefersStatusBarHidden {
            scheduleSnapshot()
        }

        return viewController.prefersStatusBarHidden
    }

    var providesPresentationContextTransitionStyle: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.providesPresentationContextTransitionStyle
        }

        if viewController.providesPresentationContextTransitionStyle != store.latest.providesPresentationContextTransitionStyle {
            scheduleSnapshot()
        }

        return viewController.providesPresentationContextTransitionStyle
    }

    var restorationClassName: String? {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.restorationClassName
        }

        if viewController.restorationClassName != store.latest.restorationClassName {
            scheduleSnapshot()
        }

        return viewController.restorationClassName
    }

    var restorationIdentifier: String? {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.restorationIdentifier
        }

        if viewController.restorationIdentifier != store.latest.restorationIdentifier {
            scheduleSnapshot()
        }

        return viewController.restorationIdentifier
    }

    var restoresFocusAfterTransition: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.restoresFocusAfterTransition
        }

        if viewController.restoresFocusAfterTransition != store.latest.restoresFocusAfterTransition {
            scheduleSnapshot()
        }

        return viewController.restoresFocusAfterTransition
    }

    var shouldAutomaticallyForwardAppearanceMethods: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.shouldAutomaticallyForwardAppearanceMethods
        }

        if viewController.shouldAutomaticallyForwardAppearanceMethods != store.latest.shouldAutomaticallyForwardAppearanceMethods {
            scheduleSnapshot()
        }

        return viewController.shouldAutomaticallyForwardAppearanceMethods
    }

    var systemMinimumLayoutMargins: NSDirectionalEdgeInsets {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.systemMinimumLayoutMargins
        }

        if viewController.systemMinimumLayoutMargins != store.latest.systemMinimumLayoutMargins {
            scheduleSnapshot()
        }

        return viewController.systemMinimumLayoutMargins
    }

    var title: String? {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.title
        }

        if viewController.title != store.latest.title {
            scheduleSnapshot()
        }

        return viewController.title
    }

    var viewRespectsSystemMinimumLayoutMargins: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest.viewRespectsSystemMinimumLayoutMargins
        }

        if viewController.viewRespectsSystemMinimumLayoutMargins != store.latest.viewRespectsSystemMinimumLayoutMargins {
            scheduleSnapshot()
        }

        return viewController.viewRespectsSystemMinimumLayoutMargins
    }
}

private extension UIViewController {
    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle {
        .init(rawValue: overrideUserInterfaceStyle) ?? .unspecified
    }

    var restorationClassName: String? {
        guard let restorationClass = restorationClass else { return nil }

        return String(describing: restorationClass)
    }
}
