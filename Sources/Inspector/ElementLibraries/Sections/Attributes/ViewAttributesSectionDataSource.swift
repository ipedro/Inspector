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
    final class ViewAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "View"

        private weak var view: UIView?

        init?(with object: NSObject) {
            guard let view = object as? UIView else { return nil }

            self.view = view
        }

        private enum Property: String, Swift.CaseIterable {
            case contentMode = "Content Mode"
            case semanticContentAttribute = "Semantic Content"
            case tag = "Tag"
            case accessibilityGroup = "Accessibility"
            case accessibilityIdentifier = "Accessibility Identifier"
            case accessibilityIdentifierFooter
            case accessibilityLabel = "Accessibility Label"
            case accessibilityLabelFooter
            case groupInteraction = "Interaction"
            case isUserInteractionEnabled = "User Interaction Enabled"
            case isMultipleTouchEnabled = "Multiple Touch Enabled"
            case groupAlphaAndColors = "Alpha And Colors"
            case alpha = "Alpha"
            case backgroundColor = "Background"
            case tintColor = "Tint"
            case groupDrawing = "Drawing"
            case isOpaque = "Opaque"
            case isHidden = "Hidden"
            case clearsContextBeforeDrawing = "Clears Graphic Context"
            case clipsToBounds = "Clips To Bounds"
            case autoresizesSubviews = "Autoresize Subviews"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let view else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .contentMode:
                    return .init(
                        descriptor: .init(
                            id: "content-mode",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: UIView.ContentMode.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                            editability: .editable
                        ),
                        read: { .selection(UIView.ContentMode.allCases.firstIndex(of: view.contentMode)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            view.contentMode = UIView.ContentMode.allCases[index]
                        }
                    )
                case .semanticContentAttribute:
                    return .init(
                        descriptor: .init(
                            id: "semantic-content-attribute",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: UISemanticContentAttribute.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                            editability: .editable
                        ),
                        read: { .selection(UISemanticContentAttribute.allCases.firstIndex(of: view.semanticContentAttribute)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            view.semanticContentAttribute = UISemanticContentAttribute.allCases[index]
                        }
                    )
                case .tag:
                    return .init(
                        descriptor: .init(
                            id: "tag",
                            title: property.rawValue,
                            kind: .stepper,
                            value: .number(.init(min: 0, max: 100, step: 1, isDecimal: false)),
                            editability: .editable
                        ),
                        read: { .number(Double(view.tag)) },
                        write: { newValue in
                            guard case let .number(value) = newValue else { return }
                            view.tag = Int(value)
                        }
                    )
                case .accessibilityLabel:
                    return .init(
                        descriptor: .init(
                            id: "accessibility-label",
                            title: property.rawValue,
                            kind: .textView,
                            value: .string(.init(multiline: true, placeholder: view.accessibilityLabel?.trimmed ?? property.rawValue, allowsNil: true)),
                            editability: .editable
                        ),
                        read: { .string(view.accessibilityLabel) },
                        write: { newValue in
                            guard case let .string(value) = newValue else { return }
                            view.accessibilityLabel = value
                        }
                    )
                case .accessibilityIdentifierFooter:
                    return .init(
                        descriptor: .init(id: "accessibility-identifier-footer", title: "", kind: .note, value: .none, editability: .readOnly, presentation: .init(subtitle: "An identifier can be used to uniquely identify an element in the scripts you write using the UI Automation interfaces. Using an identifier allows you to avoid inappropriately setting or accessing an element’s accessibility label.", noteStyle: .info)),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .accessibilityLabelFooter:
                    return .init(
                        descriptor: .init(id: "accessibility-label-footer", title: "", kind: .note, value: .none, editability: .readOnly, presentation: .init(subtitle: "A succinct label in a localized string that identifies the accessibility element to the user.", noteStyle: .info)),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .accessibilityIdentifier:
                    return .init(
                        descriptor: .init(
                            id: "accessibility-identifier",
                            title: property.rawValue,
                            kind: .textField,
                            value: .string(.init(multiline: false, placeholder: view.accessibilityIdentifier?.trimmed ?? property.rawValue, allowsNil: true)),
                            editability: .editable
                        ),
                        read: { .string(view.accessibilityIdentifier) },
                        write: { newValue in
                            guard case let .string(value) = newValue else { return }
                            view.accessibilityIdentifier = value
                            view._highlightView?.updateElementName()
                        }
                    )
                case .groupInteraction, .accessibilityGroup, .groupDrawing:
                    return .init(
                        descriptor: .init(id: property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased(), title: property.rawValue, kind: .group, value: .none, editability: .readOnly),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .isUserInteractionEnabled:
                    return .init(
                        descriptor: .init(id: "is-user-interaction-enabled", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                        read: {
                            if let element = view._highlightView?.element as? ViewHierarchyElement {
                                return .bool(element.isUnderlyingViewUserInteractionEnabled)
                            }
                            return .bool(view.isUserInteractionEnabled)
                        },
                        write: { newValue in
                            guard case let .bool(isEnabled) = newValue else { return }
                            if let element = view._highlightView?.element as? ViewHierarchyElement {
                                element.isUnderlyingViewUserInteractionEnabled = isEnabled
                            } else {
                                view.isUserInteractionEnabled = isEnabled
                            }
                        }
                    )
                case .isMultipleTouchEnabled:
                    return .init(descriptor: .init(id: "is-multiple-touch-enabled", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(view.isMultipleTouchEnabled) }, write: { newValue in guard case let .bool(v) = newValue else { return }; view.isMultipleTouchEnabled = v })
                case .groupAlphaAndColors:
                    return .init(descriptor: .init(id: "group-alpha-and-colors", title: "", kind: .separator, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
                case .alpha:
                    return .init(
                        descriptor: .init(id: "alpha", title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 1, step: 0.05, isDecimal: true)), editability: .editable),
                        read: { .number(Double(view.alpha)) },
                        write: { newValue in guard case let .number(v) = newValue else { return }; view.alpha = CGFloat(v) }
                    )
                case .backgroundColor:
                    return .init(descriptor: .init(id: "background-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable), read: { .color(view.backgroundColor) }, write: { newValue in guard case let .color(v) = newValue else { return }; view.backgroundColor = v })
                case .tintColor:
                    return .init(descriptor: .init(id: "tint-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable), read: { .color(view.tintColor) }, write: { newValue in guard case let .color(v) = newValue else { return }; view.tintColor = v })
                case .isOpaque:
                    return .init(descriptor: .init(id: "is-opaque", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(view.isOpaque) }, write: { newValue in guard case let .bool(v) = newValue else { return }; view.isOpaque = v })
                case .isHidden:
                    return .init(descriptor: .init(id: "is-hidden", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(view.isHidden) }, write: { newValue in guard case let .bool(v) = newValue else { return }; view.isHidden = v })
                case .clearsContextBeforeDrawing:
                    return .init(descriptor: .init(id: "clears-context-before-drawing", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(view.clearsContextBeforeDrawing) }, write: { newValue in guard case let .bool(v) = newValue else { return }; view.clearsContextBeforeDrawing = v })
                case .clipsToBounds:
                    return .init(descriptor: .init(id: "clips-to-bounds", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(view.clipsToBounds) }, write: { newValue in guard case let .bool(v) = newValue else { return }; view.clipsToBounds = v })
                case .autoresizesSubviews:
                    return .init(descriptor: .init(id: "autoresizes-subviews", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(view.autoresizesSubviews) }, write: { newValue in guard case let .bool(v) = newValue else { return }; view.autoresizesSubviews = v })
                }
            }
        }
    }
}
