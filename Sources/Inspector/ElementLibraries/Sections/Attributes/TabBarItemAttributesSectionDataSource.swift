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
    final class TabBarItemAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Tab Bar Item"

        private weak var tabBarItem: UITabBarItem?

        init?(with object: NSObject) {
            guard
                let viewController = object as? UIViewController,
                let tabBarItem = viewController.tabBarItem
            else {
                return nil
            }

            self.tabBarItem = tabBarItem
        }

        private enum Property: String, Swift.CaseIterable {
            case badgeValue = "Badge"
            case badgeColor = "Badge Color"
            case selectedImage = "Selected Image"
            case titlePositionAdjustment = "Title Position"
            case groupDragAndDrop = "Drag and Drop"
            case isSpringLoaded = "Spring Loaded"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let tabBarItem else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .badgeValue:
                    .init(
                        descriptor: .init(
                            id: "badge-value",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, placeholder: "Value", allowsNil: true)),
                            editability: .editable,
                            presentation: .init(axis: .vertical)
                        ),
                        read: { .string(tabBarItem.badgeValue) },
                        write: { newValue in
                            guard case let .string(value) = newValue else { return }
                            tabBarItem.badgeValue = value
                        }
                    )
                case .badgeColor:
                    .init(
                        descriptor: .init(
                            id: "badge-color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(tabBarItem.badgeColor) },
                        write: { newValue in
                            guard case let .color(color) = newValue else { return }
                            tabBarItem.badgeColor = color
                        },
                        runtimePresentation: .init(emptyTitle: "Default")
                    )
                case .selectedImage:
                    .init(
                        descriptor: .init(
                            id: "selected-image",
                            title: property.rawValue,
                            kind: .preview,
                            value: .none,
                            editability: .editable
                        ),
                        read: { .image(tabBarItem.selectedImage) },
                        write: { newValue in
                            guard case let .image(image) = newValue else { return }
                            tabBarItem.selectedImage = image
                        }
                    )
                case .titlePositionAdjustment:
                    .init(
                        descriptor: .init(
                            id: "title-position-adjustment",
                            title: property.rawValue,
                            kind: .preview,
                            value: .offset,
                            editability: .editable
                        ),
                        read: { .offset(tabBarItem.titlePositionAdjustment) },
                        write: { newValue in
                            guard case let .offset(offset) = newValue else { return }
                            tabBarItem.titlePositionAdjustment = offset
                        }
                    )
                case .groupDragAndDrop:
                    .init(
                        descriptor: .init(
                            id: "drag-and-drop-group",
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .isSpringLoaded:
                    .init(
                        descriptor: .init(
                            id: "is-spring-loaded",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(tabBarItem.isSpringLoaded) },
                        write: { newValue in
                            guard case let .bool(isSpringLoaded) = newValue else { return }
                            tabBarItem.isSpringLoaded = isSpringLoaded
                        }
                    )
                }
            }
        }
    }
}
