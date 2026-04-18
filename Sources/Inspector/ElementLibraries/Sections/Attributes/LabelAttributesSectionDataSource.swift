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
    final class LabelAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Label"

        private weak var label: UILabel?

        init?(with object: NSObject) {
            guard let label = object as? UILabel else { return nil }

            self.label = label
        }

        private enum Property: String, Swift.CaseIterable {
            case text = "Text"
            case textColor = "Text Color"
            case fontName = "Font Name"
            case fontSize = "Font Size"
            case adjustsFontSizeToFitWidth = "Automatically Adjusts Font"
            case textAlignment = "Alignment"
            case numberOfLines = "Lines"
            case groupBehavior = "Behavior"
            case isEnabled = "Enabled"
            case isHighlighted = "Highlighted"
            case separator0 = "Separator0"
            case baseline = "Baseline"
            case lineBreak = "Line Break"
            case autoShrink = "Auto Shrink"
            case allowsDefaultTighteningForTruncation = "Tighten Letter Spacing"
            case separator1 = "Separator1"
            case highlightedTextColor = "Highlighted Color"
            case shadowColor = "Shadow"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let label else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .text:
                    return .init(
                        descriptor: .init(id: "text", title: property.rawValue, kind: .textView, value: .string(.init(multiline: true, placeholder: label.text ?? property.rawValue, allowsNil: true)), editability: .editable),
                        read: { .string(label.text) },
                        write: { newValue in guard case let .string(text) = newValue else { return }; label.text = text }
                    )
                case .textColor:
                    return .init(descriptor: .init(id: "text-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable), read: { .color(label.textColor) }, write: { newValue in guard case let .color(color) = newValue else { return }; label.textColor = color })
                case .fontName:
                    return .init(
                        descriptor: .init(id: "font-name", title: property.rawValue, kind: .options, value: .selection(.init(options: FontReference.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable, presentation: .init(axis: .vertical)),
                        read: { .selection(FontReference.firstIndex(of: label.font.fontName)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue,
                                  let index,
                                  let font = FontReference.font(at: index, size: label.font.pointSize) else { return }
                            label.font = font
                        },
                        runtimePresentation: .init(selectionOptionIcons: FontReference.allCases.map(\.icon))
                    )
                case .fontSize:
                    return .init(
                        descriptor: .init(id: "font-size", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 256, step: 1, isDecimal: true)), editability: .editable),
                        read: { .number(Double(label.font.pointSize)) },
                        write: { newValue in guard case let .number(value) = newValue else { return }; label.font = label.font.withSize(CGFloat(value)) }
                    )
                case .adjustsFontSizeToFitWidth:
                    return .init(descriptor: .init(id: "adjusts-font-size-to-fit-width", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(label.adjustsFontSizeToFitWidth) }, write: { newValue in guard case let .bool(v) = newValue else { return }; label.adjustsFontSizeToFitWidth = v })
                case .textAlignment:
                    let allCases = NSTextAlignment.allCases.withImages
                    return .init(
                        descriptor: .init(id: "text-alignment", title: property.rawValue, kind: .imageButtons, value: .selection(.init(options: allCases.enumerated().map { .init(id: "\($0.offset)", title: "\($0.offset)") }, allowsNil: true)), editability: .editable),
                        read: { .selection(allCases.firstIndex(of: label.textAlignment)) },
                        write: { newValue in guard case let .selection(index) = newValue, let index else { return }; label.textAlignment = allCases[index] },
                        runtimePresentation: .init(selectionImages: allCases.compactMap(\.image))
                    )
                case .numberOfLines:
                    return .init(descriptor: .init(id: "number-of-lines", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 100, step: 1, isDecimal: false)), editability: .editable), read: { .number(Double(label.numberOfLines)) }, write: { newValue in guard case let .number(v) = newValue else { return }; label.numberOfLines = Int(v) })
                case .groupBehavior:
                    return .init(descriptor: .init(id: "group-behavior", title: property.rawValue, kind: .group, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
                case .isEnabled:
                    return .init(descriptor: .init(id: "is-enabled", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(label.isEnabled) }, write: { newValue in guard case let .bool(v) = newValue else { return }; label.isEnabled = v })
                case .isHighlighted:
                    return .init(descriptor: .init(id: "is-highlighted", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(label.isHighlighted) }, write: { newValue in guard case let .bool(v) = newValue else { return }; label.isHighlighted = v })
                case .separator0, .separator1:
                    return .init(descriptor: .init(id: property.rawValue, title: "", kind: .separator, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
                case .baseline, .lineBreak, .autoShrink:
                    return nil
                case .allowsDefaultTighteningForTruncation:
                    return .init(descriptor: .init(id: "allows-default-tightening-for-truncation", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(label.allowsDefaultTighteningForTruncation) }, write: { newValue in guard case let .bool(v) = newValue else { return }; label.allowsDefaultTighteningForTruncation = v })
                case .highlightedTextColor:
                    return .init(descriptor: .init(id: "highlighted-text-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable), read: { .color(label.highlightedTextColor) }, write: { newValue in guard case let .color(color) = newValue else { return }; label.highlightedTextColor = color })
                case .shadowColor:
                    return .init(descriptor: .init(id: "shadow-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable), read: { .color(label.shadowColor) }, write: { newValue in guard case let .color(color) = newValue else { return }; label.shadowColor = color })
                }
            }
        }
    }
}
