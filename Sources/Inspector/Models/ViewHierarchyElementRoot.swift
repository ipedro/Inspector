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

final class ViewHierarchyElementRoot {
    weak var parent: ViewHierarchyElementReference?

    lazy var children = windows
        .sorted { $0.windowLevel < $1.windowLevel }
        .map { window -> ViewHierarchyElementReference in
            let windowReference = catalog.makeElement(from: window)
            windowReference.parent = self
            windowReference.isCollapsed = true

            guard let root = window.rootViewController else {
                return windowReference
            }

            let viewControllerReferences = allViewControllers(with: root).map {
                catalog.makeElement(from: $0)
            }

            Self.connect(viewControllers: viewControllerReferences, with: windowReference)

            return windowReference
        }

    var depth: Int = -1

    var isHidden: Bool = false

    var isCollapsed: Bool = true

    let latestSnapshotIdentifier: UUID = .init()

    let windows: [UIWindow]

    private let catalog: ViewHierarchyElementCatalog

    private lazy var bundleInfo: BundleInfo? = {
        guard
            let infoDictionary = Bundle.main.infoDictionary
        else {
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: infoDictionary, options: [])
            return try JSONDecoder().decode(BundleInfo.self, from: data)
        }
        catch {
            print(error)
            return nil
        }
    }()

    private let application: UIApplication

    init(
        _ application: UIApplication,
        catalog: ViewHierarchyElementCatalog
    ) {
        self.application = application
        windows = application.windows
        self.catalog = catalog
    }

    @discardableResult
    private static func connect(
        viewControllers: [ViewHierarchyElementController],
        with window: ViewHierarchyElement
    ) -> [ViewHierarchyElementReference] {
        var viewHierarchy = [ViewHierarchyElementReference]()

        window.viewHierarchy.reversed().enumerated().forEach { _, element in
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

            if let index = parent?.children.firstIndex(where: { $0 === element }) {
                parent?.children[index] = viewController
            }

            viewController.parent = parent
            viewController.rootElement = element
            viewController.children = [element]
            // must set depth as last step
            viewController.depth = depth

            viewHierarchy.insert(viewController, at: .zero)
        }
        return viewHierarchy
    }
}

extension ViewHierarchyElementRoot: ViewHierarchyElementReference {
    var viewHierarchy: [ViewHierarchyElementReference] { children.flatMap(\.viewHierarchy) }

    var underlyingObject: NSObject? { application }

    var underlyingView: UIView? { windows.first(where: \.isKeyWindow) }

    var underlyingViewController: UIViewController? { windows.first(where: \.isKeyWindow)?.rootViewController }

    func hasChanges(inRelationTo identifier: UUID) -> Bool { false }

    var iconImage: UIImage? {
        guard
            let iconName = bundleInfo?.icons?.primaryIcon.files.last,
            let appIcon = UIImage(named: iconName),
            let appIconTemplate = UIImage.icon("app-icon-template")
        else {
            return .applicationIcon
        }

        return appIcon.maskImage(with: appIconTemplate)
    }

    var canHostContextMenuInteraction: Bool { false }

    var objectIdentifier: ObjectIdentifier { ObjectIdentifier(application) }

    var canHostInspectorView: Bool { false }

    var isInternalView: Bool { false }

    var isSystemContainer: Bool { false }

    var className: String { application._className }

    var classNameWithoutQualifiers: String { className }

    var elementName: String {
        bundleInfo?.displayName ?? bundleInfo?.executableName ?? className
    }

    var displayName: String { elementName }

    var canPresentOnTop: Bool { false }

    var isUserInteractionEnabled: Bool { false }

    var frame: CGRect { UIScreen.main.bounds }

    var accessibilityIdentifier: String? { nil }

    var issues: [ViewHierarchyIssue] { [] }

    var constraintElements: [LayoutConstraintElement] { [] }

    var shortElementDescription: String {
        guard
            let identifier = bundleInfo?.identifier,
            let version = bundleInfo?.version,
            let build = bundleInfo?.build,
            let minimumOSVersion = bundleInfo?.minimumOSVersion
        else {
            return ""
        }

        return [
            className,
            "Identifier: \(identifier)",
            "Version: \(version) (\(build))",
            "Requirement: iOS \(minimumOSVersion)+"
        ]
        .joined(separator: "\n")
    }

    var elementDescription: String { shortElementDescription }

    var overrideViewHierarchyInterfaceStyle: ViewHierarchyInterfaceStyle { .unspecified }

    var traitCollection: UITraitCollection { UITraitCollection() }

    private func allViewControllers(with rootViewController: UIViewController?) -> [UIViewController] {
        guard let rootViewController = rootViewController else { return [] }
        return [rootViewController] + rootViewController.allChildren + rootViewController.allPresentedViewControllers.flatMap { [$0] + $0.allChildren }
    }
}
