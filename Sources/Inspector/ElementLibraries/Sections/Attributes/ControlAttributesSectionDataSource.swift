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
    final class ControlAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Control"

        private weak var control: UIControl?

        init?(with object: NSObject) {
            guard let control = object as? UIControl else { return nil }

            self.control = control
        }

        private enum Property: String, Swift.CaseIterable {
            case contentHorizontalAlignment = "Horizontal Alignment"
            case contentVerticalAlignment = "Vertical Alignment"
            case groupState = "State"
            case isSelected = "Selected"
            case isEnabled = "Enabled"
            case isHighlighted = "Highlighted"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let control else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .contentHorizontalAlignment:
                    let allCases = UIControl.ContentHorizontalAlignment.allCases.withImages

                    return .init(
                        descriptor: .init(
                            id: "content-horizontal-alignment",
                            title: property.rawValue,
                            kind: .imageButtons,
                            value: .selection(
                                .init(options: allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: "\($0.offset)")
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(allCases.firstIndex(of: control.contentHorizontalAlignment)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            control.contentHorizontalAlignment = allCases[newIndex]
                        },
                        runtimePresentation: .init(selectionImages: allCases.compactMap(\.image))
                    )
                case .contentVerticalAlignment:
                    let knownCases = UIControl.ContentVerticalAlignment.allCases.filter { $0.image?.withRenderingMode(.alwaysTemplate) != nil }

                    return .init(
                        descriptor: .init(
                            id: "content-vertical-alignment",
                            title: property.rawValue,
                            kind: .imageButtons,
                            value: .selection(
                                .init(options: knownCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: "\($0.offset)")
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(knownCases.firstIndex(of: control.contentVerticalAlignment)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            control.contentVerticalAlignment = UIControl.ContentVerticalAlignment.allCases[newIndex]
                        },
                        runtimePresentation: .init(selectionImages: knownCases.compactMap(\.image))
                    )
                case .groupState:
                    return .init(
                        descriptor: .init(
                            id: "group-state",
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .isSelected:
                    return .init(
                        descriptor: .init(
                            id: "is-selected",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(control.isSelected) },
                        write: { newValue in
                            guard case let .bool(isSelected) = newValue else { return }
                            control.isSelected = isSelected
                        }
                    )
                case .isEnabled:
                    return .init(
                        descriptor: .init(
                            id: "is-enabled",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(control.isEnabled) },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            control.isEnabled = isEnabled
                        }
                    )
                case .isHighlighted:
                    return .init(
                        descriptor: .init(
                            id: "is-highlighted",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(control.isHighlighted) },
                        write: { newValue in
                            guard case let .bool(isHighlighted) = newValue else { return }
                            control.isHighlighted = isHighlighted
                        }
                    )
                }
            }
        }
    }
}
