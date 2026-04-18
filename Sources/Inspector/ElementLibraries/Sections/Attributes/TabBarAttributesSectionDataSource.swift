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
    final class TabBarAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Tab Bar"

        private weak var tabBar: UITabBar?

        init?(with object: NSObject) {
            guard let tabBar = object as? UITabBar else { return nil }
            self.tabBar = tabBar
        }

        private enum Property: String, Swift.CaseIterable {
            case backgroundImage = "Background"
            case shadowImage = "Shadow"
            case selectionIndicatorImage = "Selection"
            case separator
            case style = "Style"
            case translucent = "Translucent"
            case barTintColor = "Bar Tint"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let tabBar else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .style:
                    .init(
                        descriptor: .init(
                            id: "style",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIBarStyle.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UIBarStyle.allCases.firstIndex(of: tabBar.barStyle)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            tabBar.barStyle = UIBarStyle.allCases[index]
                        }
                    )
                case .translucent:
                    .init(
                        descriptor: .init(
                            id: "translucent",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(tabBar.isTranslucent) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            tabBar.isTranslucent = isOn
                        }
                    )
                case .barTintColor:
                    .init(
                        descriptor: .init(
                            id: "bar-tint-color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(tabBar.barTintColor) },
                        write: { newValue in
                            guard case let .color(color) = newValue else { return }
                            tabBar.barTintColor = color
                        }
                    )
                case .shadowImage:
                    .init(
                        descriptor: .init(
                            id: "shadow-image",
                            title: property.rawValue,
                            kind: .preview,
                            value: .none,
                            editability: .editable
                        ),
                        read: { .image(tabBar.shadowImage) },
                        write: { newValue in
                            guard case let .image(image) = newValue else { return }
                            tabBar.shadowImage = image
                        }
                    )
                case .backgroundImage:
                    .init(
                        descriptor: .init(
                            id: "background-image",
                            title: property.rawValue,
                            kind: .preview,
                            value: .none,
                            editability: .editable
                        ),
                        read: { .image(tabBar.backgroundImage) },
                        write: { newValue in
                            guard case let .image(image) = newValue else { return }
                            tabBar.backgroundImage = image
                        }
                    )
                case .separator:
                    .init(
                        descriptor: .init(
                            id: "separator",
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .selectionIndicatorImage:
                    .init(
                        descriptor: .init(
                            id: "selection-indicator-image",
                            title: property.rawValue,
                            kind: .preview,
                            value: .none,
                            editability: .editable
                        ),
                        read: { .image(tabBar.selectionIndicatorImage) },
                        write: { newValue in
                            guard case let .image(image) = newValue else { return }
                            tabBar.selectionIndicatorImage = image
                        }
                    )
                }
            }
        }
    }
}
