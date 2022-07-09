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

public struct InspectorConfiguration {
    var elementInspectorConfiguration = ElementInspectorConfiguration()

    public var keyCommands: KeyCommandSettings = .init()

    public var snapshotExpirationTimeInterval: TimeInterval

    public var snapshotMaxCount: Int = 1

    public var showAllViewSearchQuery: String

    public var nonInspectableClassNames: [String]

    public let enableLayoutSubviewsSwizzling: Bool

    public var showFullApplicationHierarchy: Bool

    public var verbose: Bool

    public static func config(
        enableLayoutSubviewsSwizzling: Bool = false,
        nonInspectableClassNames: [String] = [],
        showAllViewSearchQuery: String = ".",
        snapshotExpiration: TimeInterval = 1,
        showFullApplicationHierarchy: Bool = false,
        verbose: Bool = false
    ) -> InspectorConfiguration {
        .init(
            snapshotExpirationTimeInterval: snapshotExpiration,
            showAllViewSearchQuery: showAllViewSearchQuery,
            nonInspectableClassNames: nonInspectableClassNames,
            enableLayoutSubviewsSwizzling: enableLayoutSubviewsSwizzling,
            showFullApplicationHierarchy: showFullApplicationHierarchy,
            verbose: verbose
        )
    }

    public static let `default` = InspectorConfiguration.config()

    var colorStyle: InspectorColorStyle {
        guard let keyWindow = ViewHierarchy(application: .shared).keyWindow else { return .light }

        switch (keyWindow.overrideUserInterfaceStyle, keyWindow.traitCollection.userInterfaceStyle) {
        case (.dark, _),
             (.unspecified, .dark):
            return .dark
        default:
            return .light
        }
    }

    let defaultLayers: [ViewHierarchyLayer] = [
        .accessibilityElements,
        .accessibilityIdentifiers,
        .accessibilityLabels,
        .activityIndicators,
        .collectionViewCells,
        .controls,
        .images,
        .maps,
        .navigationBars,
        .progressIndicators,
        .scrollViews,
        .segmentedControls,
        .stackViews,
        .staticTexts,
        .switches,
        .tabBars,
        .tableViewCells,
        .textInputs,
        .webViews
    ]

    let knownSystemContainers: [String] = [
        "UIEditingOverlayViewController",
        "UIWindow",
        "UITransitionView",
        "UIDropShadowView",
        "UILayoutContainerView",
        // Navigation
        "UIViewControllerWrapperView",
        "UINavigationTransitionView",
        // Swift UI
        "_UIHostingView",
        "PlatformViewHost",
        "PlatformGroupContainer",
        "HostingScrollView"
    ]
}
