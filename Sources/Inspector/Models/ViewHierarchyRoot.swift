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

final class ViewHierarchyRoot {
    weak var parent: ViewHierarchyElementReference?

    lazy var children: [ViewHierarchyElementReference] = windows.compactMap { window -> [ViewHierarchyElementReference] in
        let windowReference = catalog.makeElement(from: window)
        windowReference.parent = self

        guard let rootViewController = window.rootViewController else { return [] }

        let rootViewControllerReference = ViewHierarchyController(
            with: rootViewController,
            iconProvider: catalog.iconProvider,
            depth: rootViewController.view.depth,
            isCollapsed: false
        )

        let viewControllerReferences = ([rootViewControllerReference] + rootViewControllerReference.allChildren).compactMap{ $0 as? ViewHierarchyController }

        return Self.makeViewHierarchy(window: windowReference, viewControllers: viewControllerReferences)

    }.flatMap { $0 }

    var keyWindow: ViewHierarchyElementReference? {
        children.first { ($0.underlyingView as? UIWindow)?.isKeyWindow == true }
    }

    var depth: Int = .zero

    var isHidden: Bool = false

    let latestSnapshotIdentifier: UUID = UUID()

    private let windows: [UIWindow]

    private let catalog: ViewHierarchyElementCatalog

    init?(windows: [UIWindow], catalog: ViewHierarchyElementCatalog) {
        self.windows = windows
        self.catalog = catalog

    }

    private static func makeViewHierarchy(window: ViewHierarchyElement, viewControllers: [ViewHierarchyController]) -> [ViewHierarchyElementReference] {
        var viewHierarchy = [ViewHierarchyElementReference]()

        window.viewHierarchy.reversed().enumerated().forEach { index, element in
            viewHierarchy.insert(element, at: .zero)

            guard
                let viewController = viewControllers.first(where: { $0.underlyingView === element.underlyingView }),
                let element = element as? ViewHierarchyElement
            else {
                return
            }

            let depth = element.depth
            let parent = element.parent

            element.parent = viewController

            viewController.parent = parent
            viewController.rootElement = element
            viewController.children = [element]
            // must set depth as last step
            viewController.depth = depth

            if let index = parent?.children.firstIndex(where: { $0 === element }) {
                parent?.children[index] = viewController
            }

            viewHierarchy.insert(viewController, at: .zero)

        }

        return viewHierarchy
    }
}

extension ViewHierarchyRoot: ViewHierarchyElementReference {
    var debugDescription: String { elementDescription }

    var viewHierarchy: [ViewHierarchyElementReference] { children }
    
    var underlyingObject: NSObject? { UIApplication.shared }

    var underlyingView: UIView? { nil }

    var underlyingViewController: UIViewController? { nil }

    func hasChanges(inRelationTo identifier: UUID) -> Bool { false }

    var iconImage: UIImage? { nil }

    var canHostContextMenuInteraction: Bool { false }

    var objectIdentifier: ObjectIdentifier { ObjectIdentifier(UIApplication.shared) }

    var canHostInspectorView: Bool { false }

    var isInternalView: Bool { false }

    var isSystemContainer: Bool { false }

    var className: String { elementName }

    var classNameWithoutQualifiers: String { elementName }

    var elementName: String { "View Hierarchy" }

    var displayName: String { elementName }

    var canPresentOnTop: Bool { false }

    var isUserInteractionEnabled: Bool { false }

    var frame: CGRect { UIScreen.main.bounds }

    var accessibilityIdentifier: String? { nil }

    var issues: [ViewHierarchyIssue] { [] }

    var constraintElements: [LayoutConstraintElement] { [] }

    var shortElementDescription: String { "\(viewHierarchy.count) Subviews" }

    var elementDescription: String { shortElementDescription }

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle { .unspecified }

    var traitCollection: UITraitCollection { UITraitCollection() }
}
