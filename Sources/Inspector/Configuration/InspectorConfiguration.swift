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

    public var cacheExpirationTimeInterval: TimeInterval = 0.5

    public var showAllViewSearchQuery: String = "*"

    public var nonInspectableClassNames: [String] = []

    var colorStyle: InspectorColorStyle {
        guard let hostWindow = Inspector.host?.window else { return .dark }

        if #available(iOS 13.0, *) {
            switch (hostWindow.overrideUserInterfaceStyle, hostWindow.traitCollection.userInterfaceStyle) {
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
