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
                return InspectorElementProperty.textView(
                    title: property.rawValue,
                    placeholder: textView.text,
                    value: { textView.text }
                ) { text in
                    textView.text = text
                }.makeBinding(id: id)
            case .textColor:
                return InspectorElementProperty.colorPicker(
                    title: property.rawValue,
                    color: { textView.textColor }
                ) { textColor in
                    textView.textColor = textColor
                }.makeBinding(id: id)
            case .fontName:
                return InspectorElementProperty.fontNamePicker(
                    title: property.rawValue,
                    fontProvider: { textView.font }
                ) { font in
                    guard let font else { return }
                    textView.font = font
                }.makeBinding(id: id)
            case .fontSize:
                return InspectorElementProperty.fontSizeStepper(
                    title: property.rawValue,
                    fontProvider: { textView.font }
                ) { font in
                    guard let font else { return }
                    textView.font = font
                }.makeBinding(id: id)
            case .adjustsFontForContentSizeCategory:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { textView.adjustsFontForContentSizeCategory }
                ) { adjustsFontForContentSizeCategory in
                    textView.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
                }.makeBinding(id: id)
            case .textAlignment:
                let allCases = NSTextAlignment.allCases.withImages
                return InspectorElementProperty.imageButtonGroup(
                    title: property.rawValue,
                    images: allCases.compactMap(\.image),
                    selectedIndex: { allCases.firstIndex(of: textView.textAlignment) }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.textAlignment = allCases[newIndex]
                }.makeBinding(id: id)
            case .groupBehavior:
                return InspectorElementProperty.group(title: property.rawValue).makeBinding(id: id)
            case .isEditable:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { textView.isEditable }
                ) { isEditable in
                    textView.isEditable = isEditable
                }.makeBinding(id: id)
            case .isSelectable:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { textView.isSelectable }
                ) { isSelectable in
                    textView.isSelectable = isSelectable
                }.makeBinding(id: id)
            case .groupDataDetectors:
                return InspectorElementProperty.group(title: property.rawValue).makeBinding(id: id)
            case .dataDetectorPhoneNumber:
                return InspectorElementProperty.dataDetectorType(textView: textView, dataDetectorType: .phoneNumber).makeBinding(id: id)
            case .dataDetectorLink:
                return InspectorElementProperty.dataDetectorType(textView: textView, dataDetectorType: .link).makeBinding(id: id)
            case .dataDetectorAddress:
                return InspectorElementProperty.dataDetectorType(textView: textView, dataDetectorType: .address).makeBinding(id: id)
            case .dataDetectorCalendarEvent:
                return InspectorElementProperty.dataDetectorType(textView: textView, dataDetectorType: .calendarEvent).makeBinding(id: id)
            case .dataDetectorShipmentTrackingNumber:
                return InspectorElementProperty.dataDetectorType(textView: textView, dataDetectorType: .shipmentTrackingNumber).makeBinding(id: id)
            case .dataDetectorFlightNumber:
                return InspectorElementProperty.dataDetectorType(textView: textView, dataDetectorType: .flightNumber).makeBinding(id: id)
            case .dataDetectorLookupSuggestion:
                return InspectorElementProperty.dataDetectorType(textView: textView, dataDetectorType: .lookupSuggestion).makeBinding(id: id)
            case .groupTextInputTraits:
                return InspectorElementProperty.group(title: property.rawValue).makeBinding(id: id)
            case .textContentType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextContentType.allCases.map(\.description),
                    selectedIndex: {
                        guard let textContentType = textView.textContentType else { return nil }
                        return UITextContentType.allCases.firstIndex(of: textContentType)
                    }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.textContentType = UITextContentType.allCases[newIndex]
                }.makeBinding(id: id)
            case .autocapitalizationType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextAutocapitalizationType.allCases.map(\.description),
                    selectedIndex: { UITextAutocapitalizationType.allCases.firstIndex(of: textView.autocapitalizationType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.autocapitalizationType = UITextAutocapitalizationType.allCases[newIndex]
                }.makeBinding(id: id)
            case .autocorrectionType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextAutocorrectionType.allCases.map(\.description),
                    selectedIndex: { UITextAutocorrectionType.allCases.firstIndex(of: textView.autocorrectionType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.autocorrectionType = UITextAutocorrectionType.allCases[newIndex]
                }.makeBinding(id: id)
            case .smartDashesType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextSmartDashesType.allCases.map(\.description),
                    selectedIndex: { UITextSmartDashesType.allCases.firstIndex(of: textView.smartDashesType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.smartDashesType = UITextSmartDashesType.allCases[newIndex]
                }.makeBinding(id: id)
            case .smartQuotesType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextSmartQuotesType.allCases.map(\.description),
                    selectedIndex: { UITextSmartQuotesType.allCases.firstIndex(of: textView.smartQuotesType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.smartQuotesType = UITextSmartQuotesType.allCases[newIndex]
                }.makeBinding(id: id)
            case .spellCheckingType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextSpellCheckingType.allCases.map(\.description),
                    selectedIndex: { UITextSpellCheckingType.allCases.firstIndex(of: textView.spellCheckingType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.spellCheckingType = UITextSpellCheckingType.allCases[newIndex]
                }.makeBinding(id: id)
            case .keyboardType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UIKeyboardType.allCases.map(\.description),
                    selectedIndex: { UIKeyboardType.allCases.firstIndex(of: textView.keyboardType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.keyboardType = UIKeyboardType.allCases[newIndex]
                }.makeBinding(id: id)
            case .keyboardAppearance:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UIKeyboardAppearance.allCases.map(\.description),
                    selectedIndex: { UIKeyboardAppearance.allCases.firstIndex(of: textView.keyboardAppearance) }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.keyboardAppearance = UIKeyboardAppearance.allCases[newIndex]
                }.makeBinding(id: id)
            case .returnKey:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UIReturnKeyType.allCases.map(\.description),
                    selectedIndex: { UIReturnKeyType.allCases.firstIndex(of: textView.returnKeyType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textView.returnKeyType = UIReturnKeyType.allCases[newIndex]
                }.makeBinding(id: id)
            case .enablesReturnKeyAutomatically:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { textView.enablesReturnKeyAutomatically }
                ) { enablesReturnKeyAutomatically in
                    textView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
                }.makeBinding(id: id)
            case .isSecureTextEntry:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { textView.isSecureTextEntry }
                ) { isSecureTextEntry in
                    textView.isSecureTextEntry = isSecureTextEntry
                }.makeBinding(id: id)
            }
        }
    }
}
