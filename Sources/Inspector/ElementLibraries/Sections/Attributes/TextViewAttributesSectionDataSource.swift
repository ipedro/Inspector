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
    final class TextViewAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Text View"

        private weak var textView: UITextView?

        init?(with object: NSObject) {
            guard let textView = object as? UITextView else { return nil }
            self.textView = textView
        }

        private enum Property: String, Swift.CaseIterable {
            case text = "Text"
            case textColor = "Color"
            case fontName = "Font Name"
            case fontSize = "Font Size"
            case adjustsFontForContentSizeCategory = "Automatically Adjusts Font"
            case textAlignment = "Alignment"
            case groupBehavior = "Behavior"
            case isEditable = "Editable"
            case isSelectable = "Selectable"
            case groupDataDetectors = "Data Detectors"
            case dataDetectorPhoneNumber = "Phone Number"
            case dataDetectorLink = "Link"
            case dataDetectorAddress = "Address"
            case dataDetectorCalendarEvent = "Calendar Event"
            case dataDetectorShipmentTrackingNumber = "Shipment Tracking Number"
            case dataDetectorFlightNumber = "Flight Number"
            case dataDetectorLookupSuggestion = "Lookup Suggestion"
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
            guard let textView else { return [] }
            return Property.allCases.compactMap { property in
                binding(for: property, textView: textView)
            }
        }

        private func binding(for property: Property, textView: UITextView) -> InspectorPropertyBinding? {
            let id = property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased()
            switch property {
            case .text:
                return .init(
                    descriptor: .init(
                        id: id,
                        title: property.rawValue,
                        kind: .textView,
                        value: .string(.init(multiline: true, placeholder: textView.text, allowsNil: true)),
                        editability: .editable
                    ),
                    read: { .string(textView.text) },
                    write: { newValue in
                        guard case let .string(text) = newValue else { return }
                        textView.text = text
                    }
                )
            case .textColor:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                    read: { .color(textView.textColor) },
                    write: { newValue in
                        guard case let .color(color) = newValue else { return }
                        textView.textColor = color
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
                        let fontName = textView.font?.fontName ?? UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
                        return .selection(FontReference.firstIndex(of: fontName))
                    },
                    write: { newValue in
                        guard case let .selection(index) = newValue,
                              let index,
                              let font = FontReference.font(at: index, size: textView.font?.pointSize ?? UIFont.systemFontSize) else { return }
                        textView.font = font
                    },
                    runtimePresentation: .init(selectionOptionIcons: FontReference.allCases.map(\.icon))
                )
            case .fontSize:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, max: 256, step: 1, isDecimal: true)), editability: .editable),
                    read: { .number(Double(textView.font?.pointSize ?? UIFont.systemFontSize)) },
                    write: { newValue in
                        guard case let .number(value) = newValue, let font = textView.font else { return }
                        textView.font = font.withSize(CGFloat(value))
                    }
                )
            case .adjustsFontForContentSizeCategory:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(textView.adjustsFontForContentSizeCategory) }, write: { newValue in guard case let .bool(v) = newValue else { return }; textView.adjustsFontForContentSizeCategory = v })
            case .textAlignment:
                let allCases = NSTextAlignment.allCases.withImages
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .imageButtons, value: .selection(.init(options: allCases.enumerated().map { .init(id: "\($0.offset)", title: "\($0.offset)") }, allowsNil: true)), editability: .editable),
                    read: { .selection(allCases.firstIndex(of: textView.textAlignment)) },
                    write: { newValue in
                        guard case let .selection(index) = newValue, let index else { return }
                        textView.textAlignment = allCases[index]
                    },
                    runtimePresentation: .init(selectionImages: allCases.compactMap(\.image))
                )
            case .groupBehavior, .groupDataDetectors, .groupTextInputTraits:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .group, value: .none, editability: .readOnly), read: { .none }, write: nil, refreshHint: .none)
            case .isEditable:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(textView.isEditable) }, write: { newValue in guard case let .bool(v) = newValue else { return }; textView.isEditable = v })
            case .isSelectable:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(textView.isSelectable) }, write: { newValue in guard case let .bool(v) = newValue else { return }; textView.isSelectable = v })
            case .dataDetectorPhoneNumber:
                return dataDetectorBinding(title: property.rawValue, type: .phoneNumber, textView: textView, id: id)
            case .dataDetectorLink:
                return dataDetectorBinding(title: property.rawValue, type: .link, textView: textView, id: id)
            case .dataDetectorAddress:
                return dataDetectorBinding(title: property.rawValue, type: .address, textView: textView, id: id)
            case .dataDetectorCalendarEvent:
                return dataDetectorBinding(title: property.rawValue, type: .calendarEvent, textView: textView, id: id)
            case .dataDetectorShipmentTrackingNumber:
                return dataDetectorBinding(title: property.rawValue, type: .shipmentTrackingNumber, textView: textView, id: id)
            case .dataDetectorFlightNumber:
                return dataDetectorBinding(title: property.rawValue, type: .flightNumber, textView: textView, id: id)
            case .dataDetectorLookupSuggestion:
                return dataDetectorBinding(title: property.rawValue, type: .lookupSuggestion, textView: textView, id: id)
            case .textContentType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextContentType.allCases.map(\.description), selectedIndex: {
                    guard let textContentType = textView.textContentType else { return nil }
                    return UITextContentType.allCases.firstIndex(of: textContentType)
                }, apply: { index in
                    textView.textContentType = UITextContentType.allCases[index]
                })
            case .autocapitalizationType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextAutocapitalizationType.allCases.map(\.description), selectedIndex: { UITextAutocapitalizationType.allCases.firstIndex(of: textView.autocapitalizationType) }, apply: { index in
                    textView.autocapitalizationType = UITextAutocapitalizationType.allCases[index]
                })
            case .autocorrectionType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextAutocorrectionType.allCases.map(\.description), selectedIndex: { UITextAutocorrectionType.allCases.firstIndex(of: textView.autocorrectionType) }, apply: { index in
                    textView.autocorrectionType = UITextAutocorrectionType.allCases[index]
                })
            case .smartDashesType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextSmartDashesType.allCases.map(\.description), selectedIndex: { UITextSmartDashesType.allCases.firstIndex(of: textView.smartDashesType) }, apply: { index in
                    textView.smartDashesType = UITextSmartDashesType.allCases[index]
                })
            case .smartQuotesType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextSmartQuotesType.allCases.map(\.description), selectedIndex: { UITextSmartQuotesType.allCases.firstIndex(of: textView.smartQuotesType) }, apply: { index in
                    textView.smartQuotesType = UITextSmartQuotesType.allCases[index]
                })
            case .spellCheckingType:
                return optionsBinding(id: id, title: property.rawValue, options: UITextSpellCheckingType.allCases.map(\.description), selectedIndex: { UITextSpellCheckingType.allCases.firstIndex(of: textView.spellCheckingType) }, apply: { index in
                    textView.spellCheckingType = UITextSpellCheckingType.allCases[index]
                })
            case .keyboardType:
                return optionsBinding(id: id, title: property.rawValue, options: UIKeyboardType.allCases.map(\.description), selectedIndex: { UIKeyboardType.allCases.firstIndex(of: textView.keyboardType) }, apply: { index in
                    textView.keyboardType = UIKeyboardType.allCases[index]
                })
            case .keyboardAppearance:
                return optionsBinding(id: id, title: property.rawValue, options: UIKeyboardAppearance.allCases.map(\.description), selectedIndex: { UIKeyboardAppearance.allCases.firstIndex(of: textView.keyboardAppearance) }, apply: { index in
                    textView.keyboardAppearance = UIKeyboardAppearance.allCases[index]
                })
            case .returnKey:
                return optionsBinding(id: id, title: property.rawValue, options: UIReturnKeyType.allCases.map(\.description), selectedIndex: { UIReturnKeyType.allCases.firstIndex(of: textView.returnKeyType) }, apply: { index in
                    textView.returnKeyType = UIReturnKeyType.allCases[index]
                })
            case .enablesReturnKeyAutomatically:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(textView.enablesReturnKeyAutomatically) }, write: { newValue in guard case let .bool(v) = newValue else { return }; textView.enablesReturnKeyAutomatically = v })
            case .isSecureTextEntry:
                return .init(descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(textView.isSecureTextEntry) }, write: { newValue in guard case let .bool(v) = newValue else { return }; textView.isSecureTextEntry = v })
            }
        }

        private func dataDetectorBinding(title: String, type: UIDataDetectorTypes, textView: UITextView, id: String) -> InspectorPropertyBinding {
            .init(
                descriptor: .init(id: id, title: title, kind: .toggle, value: .bool, editability: .editable),
                read: { .bool(textView.dataDetectorTypes.contains(type)) },
                write: { newValue in
                    guard case let .bool(isOn) = newValue else { return }
                    var dataDetectors = textView.dataDetectorTypes
                    if isOn { _ = dataDetectors.insert(type).memberAfterInsert }
                    else { dataDetectors.remove(type) }
                    textView.dataDetectorTypes = dataDetectors
                }
            )
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
