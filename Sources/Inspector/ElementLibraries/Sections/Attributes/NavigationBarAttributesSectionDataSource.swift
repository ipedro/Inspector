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
    final class NavigationBarAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Navigation Bar"

        private weak var navigationBar: UINavigationBar?

        init?(with object: NSObject) {
            guard let navigationBar = object as? UINavigationBar else { return nil }

            self.navigationBar = navigationBar
        }

        private enum Property: String, Swift.CaseIterable {
            case style = "Style"
            case translucent = "Translucent"
            case prefersLargeTitltes = "Prefers Large Titles"
            case barTintColor = "Bar Tint"
            case shadowImage = "Shadow"
            case backIndicatorImage = "Back"
            case backIndicatorTransitionMaskImage = "Back Mask"
            case separator0
            case groupTitleTextAttributes = "Title Text Attributes"
            case titleFontName = "Title Font Name"
            case titleFontSize = "Title Font Size"
            case titleColor = "Title Color"
            case separator1
            case groupLargeTitleTextAttributes = "Large Title Text Attributes"
            case largeTitleFontName = "Large Title Font Name"
            case largeTitleFontSize = "Large Title Font Size"
            case largeTitleColor = "Large Title Color"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let navigationBar else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .style:
                    return .init(
                        descriptor: .init(id: "style", title: property.rawValue, kind: .options, value: .selection(.init(options: UIBarStyle.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable),
                        read: { .selection(UIBarStyle.allCases.firstIndex(of: navigationBar.barStyle)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            navigationBar.barStyle = UIBarStyle.allCases[index]
                        }
                    )
                case .translucent:
                    return .init(descriptor: .init(id: "translucent", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(navigationBar.isTranslucent) }, write: { newValue in guard case let .bool(v) = newValue else { return }; navigationBar.isTranslucent = v })
                case .prefersLargeTitltes:
                    return .init(descriptor: .init(id: "prefers-large-titles", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(navigationBar.prefersLargeTitles) }, write: { newValue in guard case let .bool(v) = newValue else { return }; navigationBar.prefersLargeTitles = v })
                case .barTintColor:
                    return .init(descriptor: .init(id: "bar-tint-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable), read: { .color(navigationBar.barTintColor) }, write: { newValue in guard case let .color(v) = newValue else { return }; navigationBar.barTintColor = v })
                case .shadowImage:
                    return .init(descriptor: .init(id: "shadow-image", title: property.rawValue, kind: .preview, value: .none, editability: .editable), read: { .image(navigationBar.shadowImage) }, write: { newValue in guard case let .image(v) = newValue else { return }; navigationBar.shadowImage = v })
                case .backIndicatorImage:
                    return .init(descriptor: .init(id: "back-indicator-image", title: property.rawValue, kind: .preview, value: .none, editability: .editable), read: { .image(navigationBar.backIndicatorImage) }, write: { newValue in guard case let .image(v) = newValue else { return }; navigationBar.backIndicatorImage = v })
                case .backIndicatorTransitionMaskImage:
                    return .init(descriptor: .init(id: "back-indicator-transition-mask-image", title: property.rawValue, kind: .preview, value: .none, editability: .editable), read: { .image(navigationBar.backIndicatorTransitionMaskImage) }, write: { newValue in guard case let .image(v) = newValue else { return }; navigationBar.backIndicatorTransitionMaskImage = v })
                case .separator0, .separator1:
                    return .init(descriptor: .init(id: property.rawValue, title: "", kind: .separator, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
                case .groupTitleTextAttributes, .groupLargeTitleTextAttributes:
                    return .init(descriptor: .init(id: property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased(), title: property.rawValue, kind: .group, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
                case .titleFontName:
                    return .init(
                        descriptor: .init(id: "title-font-name", title: property.rawValue, kind: .options, value: .selection(.init(options: FontReference.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable, presentation: .init(axis: .vertical)),
                        read: {
                            let fontName = (navigationBar.titleTextAttributes?[.font] as? UIFont)?.fontName ?? UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
                            return .selection(FontReference.firstIndex(of: fontName))
                        },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            let size = (navigationBar.titleTextAttributes?[.font] as? UIFont)?.pointSize ?? UIFont.systemFontSize
                            guard let font = FontReference.font(at: index, size: size) else { return }
                            var attributes = navigationBar.titleTextAttributes ?? [:]
                            attributes[.font] = font
                            navigationBar.titleTextAttributes = attributes
                        },
                        runtimePresentation: .init(selectionOptionIcons: FontReference.allCases.map(\.icon))
                    )
                case .titleFontSize:
                    return .init(
                        descriptor: .init(id: "title-font-size", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 256, step: 1, isDecimal: true)), editability: .editable),
                        read: { .number(Double((navigationBar.titleTextAttributes?[.font] as? UIFont)?.pointSize ?? UIFont.systemFontSize)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            let currentFont = (navigationBar.titleTextAttributes?[.font] as? UIFont) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
                            var attributes = navigationBar.titleTextAttributes ?? [:]
                            attributes[.font] = currentFont.withSize(CGFloat(value))
                            navigationBar.titleTextAttributes = attributes
                        }
                    )
                case .titleColor:
                    return .init(
                        descriptor: .init(id: "title-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                        read: { .color(navigationBar.titleTextAttributes?[.foregroundColor] as? UIColor) },
                        write: { newValue in
                            guard case let .color(value) = newValue else { return }
                            var attributes = navigationBar.titleTextAttributes ?? [:]
                            attributes[.foregroundColor] = value
                            navigationBar.titleTextAttributes = attributes
                        }
                    )
                case .largeTitleFontName:
                    return .init(
                        descriptor: .init(id: "large-title-font-name", title: property.rawValue, kind: .options, value: .selection(.init(options: FontReference.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable, presentation: .init(axis: .vertical)),
                        read: {
                            let fontName = (navigationBar.largeTitleTextAttributes?[.font] as? UIFont)?.fontName ?? UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
                            return .selection(FontReference.firstIndex(of: fontName))
                        },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            let size = (navigationBar.largeTitleTextAttributes?[.font] as? UIFont)?.pointSize ?? UIFont.systemFontSize
                            guard let font = FontReference.font(at: index, size: size) else { return }
                            var attributes = navigationBar.largeTitleTextAttributes ?? [:]
                            attributes[.font] = font
                            navigationBar.largeTitleTextAttributes = attributes
                        },
                        runtimePresentation: .init(selectionOptionIcons: FontReference.allCases.map(\.icon))
                    )
                case .largeTitleFontSize:
                    return .init(
                        descriptor: .init(id: "large-title-font-size", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 256, step: 1, isDecimal: true)), editability: .editable),
                        read: { .number(Double((navigationBar.largeTitleTextAttributes?[.font] as? UIFont)?.pointSize ?? UIFont.systemFontSize)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            let currentFont = (navigationBar.largeTitleTextAttributes?[.font] as? UIFont) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
                            var attributes = navigationBar.largeTitleTextAttributes ?? [:]
                            attributes[.font] = currentFont.withSize(CGFloat(value))
                            navigationBar.largeTitleTextAttributes = attributes
                        }
                    )
                case .largeTitleColor:
                    return .init(
                        descriptor: .init(id: "large-title-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                        read: { .color(navigationBar.largeTitleTextAttributes?[.foregroundColor] as? UIColor) },
                        write: { newValue in
                            guard case let .color(value) = newValue else { return }
                            var attributes = navigationBar.largeTitleTextAttributes ?? [:]
                            attributes[.foregroundColor] = value
                            navigationBar.largeTitleTextAttributes = attributes
                        }
                    )
                }
            }
        }
    }
}
