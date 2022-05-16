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

extension DefaultElementAttributesLibrary {
    final class NavigationControllerAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Navigation Controller"

        private weak var navigationController: UINavigationController?

        init?(with object: NSObject) {
            guard let navigationController = object as? UINavigationController else {
                return nil
            }

            self.navigationController = navigationController
        }

        private enum Property: String, Swift.CaseIterable {
            case groupBarVisiblity = "Bar Visibility"
            case isNavigationBarHidden = "Shows Navigation Bar"
            case isToolbarHidden = "Shows Toolbar"
            case groupHideBars = "Hide Bars"
            case hidesBarsOnSwipe = "On Swipe"
            case hidesBarsOnTap = "On Tap"
            case hidesBarsWhenKeyboardAppears = "When Keyboard Appears"
            case hidesBarsWhenVerticallyCompact = "When Vertically Compact"
        }

        var properties: [InspectorElementProperty] {
            guard let navigationController = navigationController else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .groupHideBars, .groupBarVisiblity:
                    return .group(title: property.rawValue)

                case .isNavigationBarHidden:
                    return .switch(
                        title: property.rawValue,
                        isOn: { !navigationController.isNavigationBarHidden },
                        handler: { navigationController.setNavigationBarHidden(!$0, animated: true) }
                    )
                case .isToolbarHidden:
                    return .switch(
                        title: property.rawValue,
                        isOn: { !navigationController.isToolbarHidden },
                        handler: { navigationController.setToolbarHidden(!$0, animated: true) }
                    )
                case .hidesBarsOnSwipe:
                    return .switch(
                        title: property.rawValue,
                        isOn: { navigationController.hidesBarsOnSwipe },
                        handler: { navigationController.hidesBarsOnSwipe = $0 }
                    )
                case .hidesBarsOnTap:
                    return .switch(
                        title: property.rawValue,
                        isOn: { navigationController.hidesBarsOnTap },
                        handler: { navigationController.hidesBarsOnTap = $0 }
                    )
                case .hidesBarsWhenKeyboardAppears:
                    return .switch(
                        title: property.rawValue,
                        isOn: { navigationController.hidesBarsWhenKeyboardAppears },
                        handler: { navigationController.hidesBarsWhenKeyboardAppears = $0 }
                    )
                case .hidesBarsWhenVerticallyCompact:
                    return .switch(
                        title: property.rawValue,
                        isOn: { navigationController.hidesBarsWhenVerticallyCompact },
                        handler: { navigationController.hidesBarsWhenVerticallyCompact = $0 }
                    )
                }
            }
        }
    }
}
