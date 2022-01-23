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
    public var appearance: Appearance = .init()

    public var keyCommands: KeyCommandSettings = .init()

    public var snapshotExpirationTimeInterval: TimeInterval

    public var showAllViewSearchQuery: String

    public var nonInspectableClassNames: [String]

    public let enableLayoutSubviewsSwizzling: Bool

    public var verbose: Bool

    public init(
        snapshotExpiration: TimeInterval = 1,
        showAllViewSearchQuery: String = "*",
        nonInspectableClassNames: [String] = [],
        enableLayoutSubviewsSwizzling: Bool = false,
        verbose: Bool = false
    ) {
        self.snapshotExpirationTimeInterval = snapshotExpiration
        self.showAllViewSearchQuery = showAllViewSearchQuery
        self.nonInspectableClassNames = nonInspectableClassNames
        self.enableLayoutSubviewsSwizzling = enableLayoutSubviewsSwizzling
        self.verbose = verbose
    }

    public static let `default` = InspectorConfiguration()

    var colorStyle: InspectorColorStyle {
        guard let keyWindow = Inspector.host?.keyWindow else { return .dark }

        if #available(iOS 13.0, *) {
            switch (keyWindow.overrideUserInterfaceStyle, keyWindow.traitCollection.userInterfaceStyle) {
            case (.dark, _),
                 (.unspecified, .dark):
                return .dark
            default:
                return .light
            }
        }

        return .dark
    }

    let knownSystemContainers: [String] = [
        "UIEditingOverlayViewController",
        "UIWindow",
        "UITransitionView",
        "UIDropShadowView",
        "UILayoutContainerView",
        // Navigaiton
        "UIViewControllerWrapperView",
        "UINavigationTransitionView",
        // Swift UI
        "_UIHostingView",
        "PlatformViewHost",
        "PlatformGroupContainer",
        "HostingScrollView"
    ]
}
