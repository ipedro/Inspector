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
    final class SwitchAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Switch"

        private weak var switchControl: UISwitch?

        init?(with object: NSObject) {
            guard let switchControl = object as? UISwitch else { return nil }

            self.switchControl = switchControl
        }

        private enum Property: String, Swift.CaseIterable {
            case title = "Title"
            case preferredStyle = "Preferred Style"
            case isOn = "State"
            case onTintColor = "On Tint"
            case thumbTintColor = "Thumb Tint"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let switchControl else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .title:
                    return .init(
                        descriptor: .init(
                            id: "title",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(
                                .init(
                                    multiline: false,
                                    placeholder: switchControl.title.isNilOrEmpty ? property.rawValue : switchControl.title,
                                    allowsNil: true
                                )
                            ),
                            editability: .readOnly
                        ),
                        read: { .string(switchControl.title) },
                        write: nil
                    )
                case .preferredStyle:
                    return .init(
                        descriptor: .init(
                            id: "preferred-style",
                            title: property.rawValue,
                            kind: .textButtons,
                            value: .selection(
                                .init(options: UISwitch.Style.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable
                        ),
                        read: { .selection(UISwitch.Style.allCases.firstIndex(of: switchControl.preferredStyle)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }

                            let preferredStyle = UISwitch.Style.allCases[newIndex]

                            switchControl.preferredStyle = preferredStyle
                        }
                    )
                case .isOn:
                    return .init(
                        descriptor: .init(
                            id: "is-on",
                            title: property.rawValue,
                            kind: .toggle,
                            value: .bool,
                            editability: .editable
                        ),
                        read: { .bool(switchControl.isOn) },
                        write: { newValue in
                            guard case let .bool(isOn) = newValue else { return }
                            switchControl.setOn(isOn, animated: true)
                            switchControl.sendActions(for: .valueChanged)
                        }
                    )
                case .onTintColor:
                    return .init(
                        descriptor: .init(
                            id: "on-tint-color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(switchControl.onTintColor) },
                        write: { newValue in
                            guard case let .color(onTintColor) = newValue else { return }
                            switchControl.onTintColor = onTintColor
                        }
                    )
                case .thumbTintColor:
                    return .init(
                        descriptor: .init(
                            id: "thumb-tint-color",
                            title: property.rawValue,
                            kind: .color,
                            value: .color(allowsNil: true),
                            editability: .editable
                        ),
                        read: { .color(switchControl.thumbTintColor) },
                        write: { newValue in
                            guard case let .color(thumbTintColor) = newValue else { return }
                            switchControl.thumbTintColor = thumbTintColor
                        }
                    )
                }
            }
        }
    }
}
