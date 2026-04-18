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
    final class NavigationItemAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Navigation Item"

        private weak var navigationItem: UINavigationItem?

        init?(with object: NSObject) {
            guard let navigationItem = (object as? UIViewController)?.navigationItem else {
                return nil
            }

            self.navigationItem = navigationItem
        }

        private enum Property: String, Swift.CaseIterable {
            case title = "Title"
            case prompt = "Prompt"
            case backButtonTitle = "Back Button"
            case leftItemsSupplementBackButton = "Left Items Supplement"
            case LargeTitle = "Large Title"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let navigationItem else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .title:
                    return .init(
                        descriptor: .init(
                            id: "title",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, placeholder: navigationItem.title, allowsNil: true)),
                            editability: .editable,
                            presentation: .init(axis: .vertical)
                        ),
                        read: { .string(navigationItem.title) },
                        write: { newValue in
                            guard case let .string(value) = newValue else { return }
                            navigationItem.title = value.isNilOrEmpty ? nil : value
                        }
                    )
                case .prompt:
                    return .init(
                        descriptor: .init(
                            id: "prompt",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, placeholder: navigationItem.prompt, allowsNil: true)),
                            editability: .editable,
                            presentation: .init(axis: .vertical)
                        ),
                        read: { .string(navigationItem.prompt) },
                        write: { newValue in
                            guard case let .string(value) = newValue else { return }
                            navigationItem.prompt = value.isNilOrEmpty ? nil : value
                        }
                    )
                case .backButtonTitle:
                    return .init(
                        descriptor: .init(
                            id: "back-button-title",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, placeholder: navigationItem.backButtonTitle, allowsNil: true)),
                            editability: .editable,
                            presentation: .init(axis: .vertical)
                        ),
                        read: { .string(navigationItem.backButtonTitle) },
                        write: { newValue in
                            guard case let .string(value) = newValue else { return }
                            navigationItem.backButtonTitle = value.isNilOrEmpty ? nil : value
                        }
                    )
                case .leftItemsSupplementBackButton:
                    return .init(
                        descriptor: .init(
                            id: "left-items-supplement-back-button",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(navigationItem.leftItemsSupplementBackButton) },
                        write: { newValue in
                            guard case let .bool(value) = newValue else { return }
                            navigationItem.leftItemsSupplementBackButton = value
                        }
                    )
                case .LargeTitle:
                    return .init(
                        descriptor: .init(
                            id: "large-title",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: UINavigationItem.LargeTitleDisplayMode.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                            editability: .editable,
                            presentation: .init(axis: .vertical)
                        ),
                        read: { .selection(UINavigationItem.LargeTitleDisplayMode.allCases.firstIndex(of: navigationItem.largeTitleDisplayMode)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.allCases[index]
                        }
                    )
                }
            }
        }
    }
}

extension UINavigationItem.LargeTitleDisplayMode: CaseIterable {
    typealias AllCases = [UINavigationItem.LargeTitleDisplayMode]

    static let allCases: [UINavigationItem.LargeTitleDisplayMode] = [
        automatic,
        always,
        never
    ]
}

extension UINavigationItem.LargeTitleDisplayMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .automatic:
            "Automatic"
        case .always:
            "Always"
        case .never:
            "Never"
        @unknown default:
            if #available(iOS 17.0, *), self == .inline {
                "Inline"
            }
            else {
                "Unknown"
            }
        }
    }
}
