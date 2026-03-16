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

extension ViewHierarchyElementController {
    struct Snapshot: ViewHierarchyControllerProtocol, ExpirableProtocol, Hashable {
        let _additionalSafeAreaInsets: HashableBox<UIEdgeInsets>
        let _definesPresentationContext: Bool
        let _disablesAutomaticKeyboardDismissal: Bool
        let _edgesForExtendedLayout: HashableBox<UIRectEdge>
        let _editButtonItem: UIBarButtonItem
        let _extendedLayoutIncludesOpaqueBars: Bool
        let _isBeingPresented: Bool
        let _isEditing: Bool
        let _isModalInPresentation: Bool
        let _isSystemContainer: Bool
        let _isViewLoaded: Bool
        let _modalPresentationStyle: UIModalPresentationStyle
        let _modalTransitionStyle: UIModalTransitionStyle
        let _navigationItem: UINavigationItem
        let _nibName: String?
        let _performsActionsWhilePresentingModally: Bool
        let _preferredContentSize: HashableBox<CGSize>
        let _preferredScreenEdgesDeferringSystemGestures: HashableBox<UIRectEdge>
        let _preferredStatusBarStyle: UIStatusBarStyle
        let _preferredStatusBarUpdateAnimation: UIStatusBarAnimation
        let _prefersHomeIndicatorAutoHidden: Bool
        let _prefersPointerLocked: Bool
        let _prefersStatusBarHidden: Bool
        let _providesPresentationContextTransitionStyle: Bool
        let _restorationClassName: String?
        let _restorationIdentifier: String?
        let _restoresFocusAfterTransition: Bool
        let _shouldAutomaticallyForwardAppearanceMethods: Bool
        let _systemMinimumLayoutMargins: HashableBox<NSDirectionalEdgeInsets>
        let _title: String?
        let _viewRespectsSystemMinimumLayoutMargins: Bool
        let _depth: Int
        let expirationDate = Date().addingTimeInterval(Inspector.sharedInstance.configuration.snapshotExpirationTimeInterval)
        let identifier = UUID()
        let overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle
        let prettyClassNameWithoutQualifiers: String
        let traitCollection: UITraitCollection
        var _className: String
        var _classNameWithoutQualifiers: String
        var superclassName: String?

        init(viewController: UIViewController, depth: Int) {
            _isModalInPresentation = viewController.isModalInPresentation
            _performsActionsWhilePresentingModally = viewController.performsActionsWhilePresentingModally

            self._prefersPointerLocked = viewController.prefersPointerLocked

            if let restorationClass = viewController.restorationClass {
                _restorationClassName = String(describing: restorationClass)
            }
            else {
                _restorationClassName = nil
            }

            _additionalSafeAreaInsets = .init(wrappedValue: viewController.additionalSafeAreaInsets)
            _className = viewController.__className
            prettyClassNameWithoutQualifiers = viewController._prettyClassNameWithoutQualifiers
            _classNameWithoutQualifiers = viewController.__classNameWithoutQualifiers
            _definesPresentationContext = viewController.definesPresentationContext
            _depth = depth
            _disablesAutomaticKeyboardDismissal = viewController.disablesAutomaticKeyboardDismissal
            _edgesForExtendedLayout = .init(wrappedValue: viewController.edgesForExtendedLayout)
            _editButtonItem = viewController.editButtonItem
            _extendedLayoutIncludesOpaqueBars = viewController.extendedLayoutIncludesOpaqueBars
            _isBeingPresented = viewController.isBeingPresented
            _isEditing = viewController.isEditing
            _isSystemContainer = viewController._isSystemContainer
            _isViewLoaded = viewController.isViewLoaded
            _modalPresentationStyle = viewController.modalPresentationStyle
            _modalTransitionStyle = viewController.modalTransitionStyle
            _navigationItem = viewController.navigationItem
            _nibName = viewController.nibName
            overrideViewHierarchyInterfaceStyle = viewController.overrideViewHierarchyInterfaceStyle
            _preferredContentSize = .init(wrappedValue: viewController.preferredContentSize)
            _preferredScreenEdgesDeferringSystemGestures = .init(wrappedValue: viewController.preferredScreenEdgesDeferringSystemGestures)
            _preferredStatusBarStyle = viewController.preferredStatusBarStyle
            _preferredStatusBarUpdateAnimation = viewController.preferredStatusBarUpdateAnimation
            _prefersHomeIndicatorAutoHidden = viewController.prefersHomeIndicatorAutoHidden
            _prefersStatusBarHidden = viewController.prefersStatusBarHidden
            _providesPresentationContextTransitionStyle = viewController.providesPresentationContextTransitionStyle
            _restorationIdentifier = viewController.restorationIdentifier
            _restoresFocusAfterTransition = viewController.restoresFocusAfterTransition
            _shouldAutomaticallyForwardAppearanceMethods = viewController.shouldAutomaticallyForwardAppearanceMethods
            superclassName = viewController._superclassName
            _systemMinimumLayoutMargins = .init(wrappedValue: viewController.systemMinimumLayoutMargins)
            _title = viewController.title
            traitCollection = viewController.traitCollection
            _viewRespectsSystemMinimumLayoutMargins = viewController.viewRespectsSystemMinimumLayoutMargins
        }
    }
}

final class ViewHierarchyElementController: CustomDebugStringConvertible {
    var debugDescription: String {
        String(describing: store.latest)
    }

    var cachedIconImage: UIImage? { iconImage }

    var iconImage: UIImage? {
        let defaultIcon = iconProvider?.value(for: underlyingViewController)

        if underlyingViewController?.tabBarController?.selectedViewController === underlyingViewController {
            return underlyingViewController?.tabBarItem.selectedImage ?? defaultIcon
        }
        else {
            return underlyingViewController?.tabBarItem.image ?? defaultIcon
        }
    }

    let iconProvider: ViewHierarchyElementIconProvider?

    weak var underlyingViewController: UIViewController?

    weak var parent: ViewHierarchyElementReference?

    private var store: SnapshotStore<Snapshot>

    var isCollapsed: Bool

    var _depth: Int {
        didSet {
            children.forEach { $0._depth = _depth + 1 }
        }
    }

    var rootElement: ViewHierarchyElementReference

    private(set) lazy var deepestAbsoulteLevel: Int = children.map(\._depth).max() ?? _depth

    lazy var children: [ViewHierarchyElementReference] = makeChildren()

    var allChildren: [ViewHierarchyElementReference] {
        children.reversed().flatMap { [$0] + $0.allChildren }
    }

    // MARK: - Computed Properties

    var allParents: [ViewHierarchyElementReference] {
        var array = [ViewHierarchyElementReference]()

        if let parent {
            array.append(parent)
            array.append(contentsOf: parent.allParents)
        }

        return array
    }

    var deepestRelativeLevel: Int {
        deepestAbsoulteLevel - _depth
    }

    let _objectIdentifier: ObjectIdentifier

    // MARK: - Init

    init(
        _ viewController: UIViewController,
        iconProvider: ViewHierarchyElementIconProvider? = .none,
        depth: Int = .zero,
        isCollapsed: Bool = false,
        parent: ViewHierarchyElementController? = nil
    ) {
        _objectIdentifier = ObjectIdentifier(viewController)
        self.isCollapsed = isCollapsed
        underlyingViewController = viewController
        _depth = depth
        self.parent = parent
        self.iconProvider = iconProvider
        rootElement = ViewHierarchyElement(
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

        store = SnapshotStore(initialSnapshot)
    }

    private func makeChildReference(from childViewController: UIViewController) -> ViewHierarchyElementController {
        ViewHierarchyElementController(
            childViewController,
            iconProvider: iconProvider,
            depth: _depth + 1,
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
                    let self,
                    let rootViewController = underlyingViewController
                else {
                    return nil
                }

                return Snapshot(
                    viewController: rootViewController,
                    depth: _depth
                )
            })
        )
    }
}

extension ViewHierarchyElementController: ViewHierarchyElementReference {
    var _canHostContextMenuInteraction: Bool {
        rootElement._canHostContextMenuInteraction
    }

    var _isSystemContainer: Bool {
        store.first._isSystemContainer
    }

    var _underlyingView: UIView? {
        underlyingViewController?.viewIfLoaded
    }

    var _underlyingObject: NSObject? {
        underlyingViewController
    }

    func hasChanges(inRelationTo identifier: UUID) -> Bool {
        _latestSnapshotIdentifier != identifier
    }

    var _latestSnapshotIdentifier: UUID {
        store.latest.identifier
    }

    var _canHostInspectorView: Bool { false }

    var _isInternalView: Bool {
        rootElement._isInternalView
    }

    var _elementName: String {
        _classNameWithoutQualifiers
    }

    var _displayName: String {
        store
            .latest
            .prettyClassNameWithoutQualifiers
            .string(appending: _title, separator: " - ")
    }

    var _canPresentOnTop: Bool {
        rootElement._canPresentOnTop
    }

    var isUserInteractionEnabled: Bool {
        rootElement.isUserInteractionEnabled
    }

    var _frame: HashableBox<CGRect> {
        rootElement._frame
    }

    var accessibilityIdentifier: String? { nil }

    var _issues: [ViewHierarchyIssue] {
        rootElement._issues
    }

    var _constraintElements: [LayoutConstraintElement] {
        rootElement._constraintElements
    }

    var _shortElementDescription: String {
        [
            _className,
            {
                guard let title = store.latest._title else {
                    return .none
                }
                return title.string(prepending: "Title:")
            }(),
            {
                guard let children = underlyingViewController?
                    .children, children.count > .zero
                else {
                    return .none
                }

                if children.count == 1 {
                    return children.first?.__className.string(prepending: "Child:")
                }

                return children.count
                    .toString()
                    .string(prepending: "Children:")
            }()
        ]
        .compactMap { $0 }
        .joined(separator: .newLine)
    }

    var _elementDescription: String {
        [
            _shortElementDescription,
            {
                guard let parent = underlyingViewController?.parent else {
                    return .none
                }
                return parent.__className.string(prepending: "Parent:")
            }(),
            "Presentation: \(store.latest._modalPresentationStyle.description)",
            "Transition: \(store.latest._modalTransitionStyle.description)"
        ]
        .compactMap { $0 }
        .joined(separator: .newLine)
    }

    var isHidden: Bool {
        get { rootElement.isHidden }
        set { rootElement.isHidden = newValue }
    }
}

extension ViewHierarchyElementController: ViewHierarchyControllerProtocol {
    var _className: String {
        store.first._className
    }

    var superclassName: String? {
        store.first.superclassName
    }

    var _classNameWithoutQualifiers: String {
        store.first._classNameWithoutQualifiers
    }

    var _additionalSafeAreaInsets: HashableBox<UIEdgeInsets> {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._additionalSafeAreaInsets
        }

        if viewController.additionalSafeAreaInsets != store.latest._additionalSafeAreaInsets.wrappedValue {
            scheduleSnapshot()
        }

        return .init(wrappedValue: viewController.additionalSafeAreaInsets)
    }

    var _definesPresentationContext: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._definesPresentationContext
        }

        if viewController.definesPresentationContext != store.latest._definesPresentationContext {
            scheduleSnapshot()
        }

        return viewController.definesPresentationContext
    }

    var _disablesAutomaticKeyboardDismissal: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._disablesAutomaticKeyboardDismissal
        }

        if viewController.disablesAutomaticKeyboardDismissal != store.latest._disablesAutomaticKeyboardDismissal {
            scheduleSnapshot()
        }

        return viewController.disablesAutomaticKeyboardDismissal
    }

    var _edgesForExtendedLayout: HashableBox<UIRectEdge> {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._edgesForExtendedLayout
        }

        if viewController.edgesForExtendedLayout != store.latest._edgesForExtendedLayout.wrappedValue {
            scheduleSnapshot()
        }

        return .init(wrappedValue: viewController.edgesForExtendedLayout)
    }

    var _editButtonItem: UIBarButtonItem {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._editButtonItem
        }

        if viewController.editButtonItem != store.latest._editButtonItem {
            scheduleSnapshot()
        }

        return viewController.editButtonItem
    }

    var _extendedLayoutIncludesOpaqueBars: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._extendedLayoutIncludesOpaqueBars
        }

        if viewController.extendedLayoutIncludesOpaqueBars != store.latest._extendedLayoutIncludesOpaqueBars {
            scheduleSnapshot()
        }

        return viewController.extendedLayoutIncludesOpaqueBars
    }

    var _isBeingPresented: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._isBeingPresented
        }

        if viewController.isBeingPresented != store.latest._isBeingPresented {
            scheduleSnapshot()
        }

        return viewController.isBeingPresented
    }

    var _isEditing: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._isEditing
        }

        if viewController.isEditing != store.latest._isEditing {
            scheduleSnapshot()
        }

        return viewController.isEditing
    }

    var _isModalInPresentation: Bool {
        guard
            store.latest.isExpired,
            let viewController = underlyingViewController
        else {
            return store.latest._isModalInPresentation
        }

        if viewController.isModalInPresentation != store.latest._isModalInPresentation {
            scheduleSnapshot()
        }

        return viewController.isModalInPresentation
    }

    var _isViewLoaded: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._isViewLoaded
        }

        if viewController.isViewLoaded != store.latest._isViewLoaded {
            scheduleSnapshot()
        }

        return viewController.isViewLoaded
    }

    var _modalPresentationStyle: UIModalPresentationStyle {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._modalPresentationStyle
        }

        if viewController.modalPresentationStyle != store.latest._modalPresentationStyle {
            scheduleSnapshot()
        }

        return viewController.modalPresentationStyle
    }

    var _modalTransitionStyle: UIModalTransitionStyle {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._modalTransitionStyle
        }

        if viewController.modalTransitionStyle != store.latest._modalTransitionStyle {
            scheduleSnapshot()
        }

        return viewController.modalTransitionStyle
    }

    var _navigationItem: UINavigationItem {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._navigationItem
        }

        if viewController.navigationItem != store.latest._navigationItem {
            scheduleSnapshot()
        }

        return viewController.navigationItem
    }

    var _nibName: String? {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._nibName
        }

        if viewController.nibName != store.latest._nibName {
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

    var _performsActionsWhilePresentingModally: Bool {
        guard
            store.latest.isExpired,
            let viewController = underlyingViewController
        else {
            return store.latest._performsActionsWhilePresentingModally
        }

        if viewController.performsActionsWhilePresentingModally != store.latest._performsActionsWhilePresentingModally {
            scheduleSnapshot()
        }

        return viewController.performsActionsWhilePresentingModally
    }

    var _preferredContentSize: HashableBox<CGSize> {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._preferredContentSize
        }

        if viewController.preferredContentSize != store.latest._preferredContentSize.wrappedValue {
            scheduleSnapshot()
        }

        return .init(wrappedValue: viewController.preferredContentSize)
    }

    var _preferredScreenEdgesDeferringSystemGestures: HashableBox<UIRectEdge> {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._preferredScreenEdgesDeferringSystemGestures
        }

        if viewController.preferredScreenEdgesDeferringSystemGestures != store.latest._preferredScreenEdgesDeferringSystemGestures.wrappedValue {
            scheduleSnapshot()
        }

        return .init(wrappedValue: viewController.preferredScreenEdgesDeferringSystemGestures)
    }

    var _preferredStatusBarStyle: UIStatusBarStyle {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._preferredStatusBarStyle
        }

        if viewController.preferredStatusBarStyle != store.latest._preferredStatusBarStyle {
            scheduleSnapshot()
        }

        return viewController.preferredStatusBarStyle
    }

    var _preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._preferredStatusBarUpdateAnimation
        }

        if viewController.preferredStatusBarUpdateAnimation != store.latest._preferredStatusBarUpdateAnimation {
            scheduleSnapshot()
        }

        return viewController.preferredStatusBarUpdateAnimation
    }

    var _prefersHomeIndicatorAutoHidden: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._prefersHomeIndicatorAutoHidden
        }

        if viewController.prefersHomeIndicatorAutoHidden != store.latest._prefersHomeIndicatorAutoHidden {
            scheduleSnapshot()
        }

        return viewController.prefersHomeIndicatorAutoHidden
    }

    var _prefersPointerLocked: Bool {
        guard
            store.latest.isExpired,
            let viewController = underlyingViewController
        else {
            return store.latest._prefersPointerLocked
        }

        if viewController.prefersPointerLocked != store.latest._prefersPointerLocked {
            scheduleSnapshot()
        }

        return viewController.prefersPointerLocked
    }

    var _prefersStatusBarHidden: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._prefersStatusBarHidden
        }

        if viewController.prefersStatusBarHidden != store.latest._prefersStatusBarHidden {
            scheduleSnapshot()
        }

        return viewController.prefersStatusBarHidden
    }

    var _providesPresentationContextTransitionStyle: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._providesPresentationContextTransitionStyle
        }

        if viewController.providesPresentationContextTransitionStyle != store.latest._providesPresentationContextTransitionStyle {
            scheduleSnapshot()
        }

        return viewController.providesPresentationContextTransitionStyle
    }

    var _restorationClassName: String? {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._restorationClassName
        }

        if viewController.restorationClassName != store.latest._restorationClassName {
            scheduleSnapshot()
        }

        return viewController.restorationClassName
    }

    var _restorationIdentifier: String? {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._restorationIdentifier
        }

        if viewController.restorationIdentifier != store.latest._restorationIdentifier {
            scheduleSnapshot()
        }

        return viewController.restorationIdentifier
    }

    var _restoresFocusAfterTransition: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._restoresFocusAfterTransition
        }

        if viewController.restoresFocusAfterTransition != store.latest._restoresFocusAfterTransition {
            scheduleSnapshot()
        }

        return viewController.restoresFocusAfterTransition
    }

    var _shouldAutomaticallyForwardAppearanceMethods: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._shouldAutomaticallyForwardAppearanceMethods
        }

        if viewController.shouldAutomaticallyForwardAppearanceMethods != store.latest._shouldAutomaticallyForwardAppearanceMethods {
            scheduleSnapshot()
        }

        return viewController.shouldAutomaticallyForwardAppearanceMethods
    }

    var _systemMinimumLayoutMargins: HashableBox<NSDirectionalEdgeInsets> {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._systemMinimumLayoutMargins
        }

        if viewController.systemMinimumLayoutMargins != store.latest._systemMinimumLayoutMargins.wrappedValue {
            scheduleSnapshot()
        }

        return .init(wrappedValue: viewController.systemMinimumLayoutMargins)
    }

    var _title: String? {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._title
        }

        if viewController.title != store.latest._title {
            scheduleSnapshot()
        }

        return viewController.title ?? viewController.tabBarItem.title
    }

    var _viewRespectsSystemMinimumLayoutMargins: Bool {
        guard store.latest.isExpired, let viewController = underlyingViewController else {
            return store.latest._viewRespectsSystemMinimumLayoutMargins
        }

        if viewController.viewRespectsSystemMinimumLayoutMargins != store.latest._viewRespectsSystemMinimumLayoutMargins {
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
        guard let restorationClass else { return nil }

        return String(describing: restorationClass)
    }
}
