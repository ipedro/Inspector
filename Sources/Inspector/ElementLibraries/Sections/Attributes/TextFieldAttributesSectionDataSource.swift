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
    final class TextFieldAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Text Field"

        private(set) weak var textField: UITextField?

        init?(with object: NSObject) {
            guard let textField = object as? UITextField else { return nil }
            self.textField = textField
        }

        private enum Property: String, Swift.CaseIterable {
            case text = "Text"
            case textColor = "Color"
            case fontName = "Font Name"
            case fontSize = "Font Size"
            case adjustsFontSizeToFitWidth = "Automatically Adjusts Font"
            case textAlignment = "Alignment"
            case placeholder = "Placeholder"
            case groupImages = "Images"
            case background = "Background Image"
            case disabledBackground = "Disabled Background Image"
            case groupBorder = "Border"
            case borderStyle = "Border Style"
            case groupClearButton = "Buttons"
            case clearButton = "Clear Button"
            case clearWhenEditingBegins = "Clear When Editing Begins"
            case groupAdditionalFontOptions = "Additional Font Options"
            case minFontSize = "Min Font Size"
            case groupTextInputTraits = "Text Input Traits"
            case textContentType = "Content Type"
            case autocapitalizationType = "Capitalization"
            case autocorrectionType = "Correction"
            case smartDashesType = "Smart Dashes"
            case smartQuotesType = "Smart Quotes"
            case spellCheckingType = "Spell Checking"
            case keyboardType = "Keyboard Type"
            case keyboardAppearance = "Keyboard Look"
            case returnKey = "Return Key"
            case enablesReturnKeyAutomatically = "Auto-enable Return Key"
            case isSecureTextEntry = "Secure Text Entry"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let textField else { return [] }
            return Property.allCases.compactMap { property in
                binding(for: property, textField: textField)
            }
        }

        private func binding(for property: Property, textField: UITextField) -> InspectorPropertyBinding? {
            let id = property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased()
            switch property {
            case .text:
                return .init(
                    descriptor: .init(
                        id: id,
                        title: property.rawValue,
                        kind: .textField,
                        value: .string(.init(multiline: false, placeholder: textField.text.isNilOrEmpty ? property.rawValue : textField.text, allowsNil: true)),
                        editability: .editable
                    ),
                    read: { .string(textField.text) },
                    write: { newValue in
                        guard case let .string(text) = newValue else { return }
                        textField.text = text
                    }
                )
            case .textColor:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                    read: { .color(textField.textColor) },
                    write: { newValue in
                        guard case let .color(color) = newValue else { return }
                        textField.textColor = color
                    }
                )
            case .fontName:
                return .init(
                    descriptor: .init(
                        id: id,
                        title: property.rawValue,
                        kind: .options,
                        value: .selection(.init(options: FontReference.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                        editability: .editable,
                        presentation: .init(axis: .vertical)
                    ),
                    read: {
                        let fontName = textField.font?.fontName ?? UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
                        return .selection(FontReference.firstIndex(of: fontName))
                    },
                    write: { newValue in
                        guard case let .selection(index) = newValue,
                              let index,
                              let font = FontReference.font(at: index, size: textField.font?.pointSize ?? UIFont.systemFontSize) else { return }
                        textField.font = font
                    },
                    runtimePresentation: .init(selectionOptionIcons: FontReference.allCases.map(\.icon))
                )
            case .fontSize:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 256, step: 1, isDecimal: true)), editability: .editable),
                    read: { .number(Double(textField.font?.pointSize ?? UIFont.systemFontSize)) },
                    write: { newValue in
                        guard case let .number(value) = newValue, let font = textField.font else { return }
                        textField.font = font.withSize(CGFloat(value))
                    }
                )
            case .adjustsFontSizeToFitWidth:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(textField.adjustsFontSizeToFitWidth) }, write: { newValue in guard case let .bool(v) = newValue else { return }; textField.adjustsFontSizeToFitWidth = v })
            case .textAlignment:
                let allCases = NSTextAlignment.allCases.withImages
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .imageButtons, value: .selection(.init(options: allCases.enumerated().map { .init(id: "\($0.offset)", title: "\($0.offset)") }, allowsNil: true)), editability: .editable),
                    read: { .selection(allCases.firstIndex(of: textField.textAlignment)) },
                    write: { newValue in
                        guard case let .selection(index) = newValue, let index else { return }
                        textField.textAlignment = allCases[index]
                    },
                    runtimePresentation: .init(selectionImages: allCases.compactMap(\.image))
                )
            case .placeholder:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .textField, value: .string(.init(multiline: false, placeholder: textField.placeholder.isNilOrEmpty ? property.rawValue : textField.placeholder, allowsNil: true)), editability: .editable),
                    read: { .string(textField.placeholder) },
                    write: { newValue in
                        guard case let .string(value) = newValue else { return }
                        textField.placeholder = value
                    }
                )
            case .groupImages:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .group, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
            case .background:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .preview, value: .none, editability: .editable), read: { .image(textField.background) }, write: { newValue in guard case let .image(image) = newValue else { return }; textField.background = image })
            case .disabledBackground:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .preview, value: .none, editability: .editable), read: { .image(textField.disabledBackground) }, write: { newValue in guard case let .image(image) = newValue else { return }; textField.disabledBackground = image })
            case .groupBorder, .groupClearButton, .groupAdditionalFontOptions:
                return .init(descriptor: .init(id: id, title: "", kind: .separator, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
            case .borderStyle:
                let allCases = UITextField.BorderStyle.allCases.withImages
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .imageButtons, value: .selection(.init(options: allCases.enumerated().map { .init(id: "\($0.offset)", title: "\($0.offset)") }, allowsNil: true)), editability: .editable, presentation: .init(axis: .vertical)),
                    read: { .selection(allCases.firstIndex(of: textField.borderStyle)) },
                    write: { newValue in
                        guard case let .selection(index) = newValue, let index else { return }
                        textField.borderStyle = allCases[index]
                    },
                    runtimePresentation: .init(selectionImages: allCases.compactMap(\.image))
                )
            case .clearButton:
                return optionsBinding(id: id, title: property.rawValue, options: UITextField.ViewMode.allCases.map(\.description), selectedIndex: { UITextField.ViewMode.allCases.firstIndex(of: textField.clearButtonMode) }, apply: { index in
                    textField.clearButtonMode = UITextField.ViewMode.allCases[index]
                })
            case .clearWhenEditingBegins:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(textField.clearsOnBeginEditing) }, write: { newValue in guard case let .bool(v) = newValue else { return }; textField.clearsOnBeginEditing = v })
            case .minFontSize:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 256, step: 1, isDecimal: true)), editability: .editable), read: { .number(Double(textField.minimumFontSize)) }, write: { newValue in guard case let .number(v) = newValue else { return }; textField.minimumFontSize = CGFloat(v) })
            case .groupTextInputTraits:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .group, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
            case .textContentType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextContentType.allCases.map(\.description), selectedIndex: {
                    guard let textContentType = textField.textContentType else { return nil }
                    return UITextContentType.allCases.firstIndex(of: textContentType)
                }, apply: { index in
                    textField.textContentType = UITextContentType.allCases[index]
                })
            case .autocapitalizationType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextAutocapitalizationType.allCases.map(\.description), selectedIndex: { UITextAutocapitalizationType.allCases.firstIndex(of: textField.autocapitalizationType) }, apply: { index in
                    textField.autocapitalizationType = UITextAutocapitalizationType.allCases[index]
                })
            case .autocorrectionType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextAutocorrectionType.allCases.map(\.description), selectedIndex: { UITextAutocorrectionType.allCases.firstIndex(of: textField.autocorrectionType) }, apply: { index in
                    textField.autocorrectionType = UITextAutocorrectionType.allCases[index]
                })
            case .smartDashesType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextSmartDashesType.allCases.map(\.description), selectedIndex: { UITextSmartDashesType.allCases.firstIndex(of: textField.smartDashesType) }, apply: { index in
                    textField.smartDashesType = UITextSmartDashesType.allCases[index]
                })
            case .smartQuotesType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextSmartQuotesType.allCases.map(\.description), selectedIndex: { UITextSmartQuotesType.allCases.firstIndex(of: textField.smartQuotesType) }, apply: { index in
                    textField.smartQuotesType = UITextSmartQuotesType.allCases[index]
                })
            case .spellCheckingType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextSpellCheckingType.allCases.map(\.description), selectedIndex: { UITextSpellCheckingType.allCases.firstIndex(of: textField.spellCheckingType) }, apply: { index in
                    textField.spellCheckingType = UITextSpellCheckingType.allCases[index]
                })
            case .keyboardType:
                return optionsBinding(id: id, title: property.rawValue, options: UIKeyboardType.allCases.map(\.description), selectedIndex: { UIKeyboardType.allCases.firstIndex(of: textField.keyboardType) }, apply: { index in
                    textField.keyboardType = UIKeyboardType.allCases[index]
                })
            case .keyboardAppearance:
                return optionsBinding(id: id, title: property.rawValue, options: UIKeyboardAppearance.allCases.map(\.description), selectedIndex: { UIKeyboardAppearance.allCases.firstIndex(of: textField.keyboardAppearance) }, apply: { index in
                    textField.keyboardAppearance = UIKeyboardAppearance.allCases[index]
                })
            case .returnKey:
                return optionsBinding(id: id, title: property.rawValue, options: UIReturnKeyType.allCases.map(\.description), selectedIndex: { UIReturnKeyType.allCases.firstIndex(of: textField.returnKeyType) }, apply: { index in
                    textField.returnKeyType = UIReturnKeyType.allCases[index]
                })
            case .enablesReturnKeyAutomatically:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(textField.enablesReturnKeyAutomatically) }, write: { newValue in guard case let .bool(v) = newValue else { return }; textField.enablesReturnKeyAutomatically = v })
            case .isSecureTextEntry:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(textField.isSecureTextEntry) }, write: { newValue in guard case let .bool(v) = newValue else { return }; textField.isSecureTextEntry = v })
            }
        }

        private func optionsBinding(id: String, title: String, options: [String], selectedIndex: @escaping () -> Int?, apply: @escaping (Int) -> Void) -> InspectorPropertyBinding {
            .init(
                descriptor: .init(id: id, title: title, kind: .options, value: .selection(.init(options: options.enumerated().map { .init(id: "\($0.offset)", title: $0.element) }, allowsNil: true)), editability: .editable),
                read: { .selection(selectedIndex()) },
                write: { newValue in
                    guard case let .selection(index) = newValue, let index else { return }
                    apply(index)
                }
            )
        }
    }
}
