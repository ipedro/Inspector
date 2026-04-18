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
                return InspectorElementProperty.textField(
                    title: property.rawValue,
                    placeholder: textField.text.isNilOrEmpty ? property.rawValue : textField.text,
                    value: { textField.text }
                ) { text in
                    textField.text = text
                }.makeBinding(id: id)
            case .textColor:
                return InspectorElementProperty.colorPicker(
                    title: property.rawValue,
                    color: { textField.textColor }
                ) { textColor in
                    textField.textColor = textColor
                }.makeBinding(id: id)
            case .fontName:
                return InspectorElementProperty.fontNamePicker(
                    title: property.rawValue,
                    fontProvider: { textField.font }
                ) { font in
                    guard let font else { return }
                    textField.font = font
                }.makeBinding(id: id)
            case .fontSize:
                return InspectorElementProperty.fontSizeStepper(
                    title: property.rawValue,
                    fontProvider: { textField.font }
                ) { font in
                    guard let font else { return }
                    textField.font = font
                }.makeBinding(id: id)
            case .textAlignment:
                let allCases = NSTextAlignment.allCases.withImages
                return InspectorElementProperty.imageButtonGroup(
                    title: property.rawValue,
                    images: allCases.compactMap(\.image),
                    selectedIndex: { allCases.firstIndex(of: textField.textAlignment) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.textAlignment = allCases[newIndex]
                }.makeBinding(id: id)
            case .placeholder:
                return InspectorElementProperty.textField(
                    title: property.rawValue,
                    placeholder: textField.placeholder.isNilOrEmpty ? property.rawValue : textField.placeholder,
                    value: { textField.placeholder }
                ) { placeholder in
                    textField.placeholder = placeholder
                }.makeBinding(id: id)
            case .groupImages:
                return InspectorElementProperty.group(title: property.rawValue).makeBinding(id: id)
            case .background:
                return InspectorElementProperty.imagePicker(
                    title: property.rawValue,
                    image: { textField.background }
                ) { background in
                    textField.background = background
                }.makeBinding(id: id)
            case .disabledBackground:
                return InspectorElementProperty.imagePicker(
                    title: property.rawValue,
                    image: { textField.disabledBackground }
                ) { disabledBackground in
                    textField.disabledBackground = disabledBackground
                }.makeBinding(id: id)
            case .groupBorder, .groupClearButton, .groupAdditionalFontOptions:
                return InspectorElementProperty.separator.makeBinding(id: id)
            case .borderStyle:
                let allCases = UITextField.BorderStyle.allCases.withImages
                return InspectorElementProperty.imageButtonGroup(
                    title: property.rawValue,
                    axis: .vertical,
                    images: allCases.compactMap(\.image),
                    selectedIndex: { allCases.firstIndex(of: textField.borderStyle) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.borderStyle = allCases[newIndex]
                }.makeBinding(id: id)
            case .clearButton:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextField.ViewMode.allCases.map(\.description),
                    selectedIndex: { UITextField.ViewMode.allCases.firstIndex(of: textField.clearButtonMode) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.clearButtonMode = UITextField.ViewMode.allCases[newIndex]
                }.makeBinding(id: id)
            case .clearWhenEditingBegins:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { textField.clearsOnBeginEditing }
                ) { clearsOnBeginEditing in
                    textField.clearsOnBeginEditing = clearsOnBeginEditing
                }.makeBinding(id: id)
            case .minFontSize:
                return InspectorElementProperty.cgFloatStepper(
                    title: property.rawValue,
                    value: { textField.minimumFontSize },
                    range: { 0...256 },
                    stepValue: { 1 }
                ) { minimumFontSize in
                    textField.minimumFontSize = minimumFontSize
                }.makeBinding(id: id)
            case .adjustsFontSizeToFitWidth:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { textField.adjustsFontSizeToFitWidth }
                ) { adjustsFontSizeToFitWidth in
                    textField.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
                }.makeBinding(id: id)
            case .groupTextInputTraits:
                return InspectorElementProperty.group(title: property.rawValue).makeBinding(id: id)
            case .textContentType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextContentType.allCases.map(\.description),
                    selectedIndex: {
                        guard let textContentType = textField.textContentType else { return nil }
                        return UITextContentType.allCases.firstIndex(of: textContentType)
                    }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.textContentType = UITextContentType.allCases[newIndex]
                }.makeBinding(id: id)
            case .autocapitalizationType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextAutocapitalizationType.allCases.map(\.description),
                    selectedIndex: { UITextAutocapitalizationType.allCases.firstIndex(of: textField.autocapitalizationType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.autocapitalizationType = UITextAutocapitalizationType.allCases[newIndex]
                }.makeBinding(id: id)
            case .autocorrectionType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextAutocorrectionType.allCases.map(\.description),
                    selectedIndex: { UITextAutocorrectionType.allCases.firstIndex(of: textField.autocorrectionType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.autocorrectionType = UITextAutocorrectionType.allCases[newIndex]
                }.makeBinding(id: id)
            case .smartDashesType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextSmartDashesType.allCases.map(\.description),
                    selectedIndex: { UITextSmartDashesType.allCases.firstIndex(of: textField.smartDashesType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.smartDashesType = UITextSmartDashesType.allCases[newIndex]
                }.makeBinding(id: id)
            case .smartQuotesType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextSmartQuotesType.allCases.map(\.description),
                    selectedIndex: { UITextSmartQuotesType.allCases.firstIndex(of: textField.smartQuotesType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.smartQuotesType = UITextSmartQuotesType.allCases[newIndex]
                }.makeBinding(id: id)
            case .spellCheckingType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UITextSpellCheckingType.allCases.map(\.description),
                    selectedIndex: { UITextSpellCheckingType.allCases.firstIndex(of: textField.spellCheckingType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.spellCheckingType = UITextSpellCheckingType.allCases[newIndex]
                }.makeBinding(id: id)
            case .keyboardType:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UIKeyboardType.allCases.map(\.description),
                    selectedIndex: { UIKeyboardType.allCases.firstIndex(of: textField.keyboardType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.keyboardType = UIKeyboardType.allCases[newIndex]
                }.makeBinding(id: id)
            case .keyboardAppearance:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UIKeyboardAppearance.allCases.map(\.description),
                    selectedIndex: { UIKeyboardAppearance.allCases.firstIndex(of: textField.keyboardAppearance) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.keyboardAppearance = UIKeyboardAppearance.allCases[newIndex]
                }.makeBinding(id: id)
            case .returnKey:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UIReturnKeyType.allCases.map(\.description),
                    selectedIndex: { UIReturnKeyType.allCases.firstIndex(of: textField.returnKeyType) }
                ) {
                    guard let newIndex = $0 else { return }
                    textField.returnKeyType = UIReturnKeyType.allCases[newIndex]
                }.makeBinding(id: id)
            case .enablesReturnKeyAutomatically:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { textField.enablesReturnKeyAutomatically }
                ) { enablesReturnKeyAutomatically in
                    textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
                }.makeBinding(id: id)
            case .isSecureTextEntry:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { textField.isSecureTextEntry }
                ) { isSecureTextEntry in
                    textField.isSecureTextEntry = isSecureTextEntry
                }.makeBinding(id: id)
            }
        }
    }
}
