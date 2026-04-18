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

import InspectorContract
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

        var propertyBindings: [InspectorPropertyBinding] {
            guard let navigationController else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .groupHideBars, .groupBarVisiblity:
                    .init(
                        descriptor: .init(
                            id: property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased(),
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .isNavigationBarHidden:
                    .init(
                        descriptor: .init(
                            id: "shows-navigation-bar",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(!navigationController.isNavigationBarHidden) },
                        write: { newValue in
                            guard case let .bool(isVisible) = newValue else { return }
                            navigationController.setNavigationBarHidden(!isVisible, animated: true)
                        }
                    )
                case .isToolbarHidden:
                    .init(
                        descriptor: .init(
                            id: "shows-toolbar",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(!navigationController.isToolbarHidden) },
                        write: { newValue in
                            guard case let .bool(isVisible) = newValue else { return }
                            navigationController.setToolbarHidden(!isVisible, animated: true)
                        }
                    )
                case .hidesBarsOnSwipe:
                    .init(
                        descriptor: .init(
                            id: "hides-bars-on-swipe",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(navigationController.hidesBarsOnSwipe) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            navigationController.hidesBarsOnSwipe = isEnabled
                        }
                    )
                case .hidesBarsOnTap:
                    .init(
                        descriptor: .init(
                            id: "hides-bars-on-tap",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(navigationController.hidesBarsOnTap) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            navigationController.hidesBarsOnTap = isEnabled
                        }
                    )
                case .hidesBarsWhenKeyboardAppears:
                    .init(
                        descriptor: .init(
                            id: "hides-bars-when-keyboard-appears",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(navigationController.hidesBarsWhenKeyboardAppears) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            navigationController.hidesBarsWhenKeyboardAppears = isEnabled
                        }
                    )
                case .hidesBarsWhenVerticallyCompact:
                    .init(
                        descriptor: .init(
                            id: "hides-bars-when-vertically-compact",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(navigationController.hidesBarsWhenVerticallyCompact) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            navigationController.hidesBarsWhenVerticallyCompact = isEnabled
                        }
                    )
                }
            }
        }
    }
}
