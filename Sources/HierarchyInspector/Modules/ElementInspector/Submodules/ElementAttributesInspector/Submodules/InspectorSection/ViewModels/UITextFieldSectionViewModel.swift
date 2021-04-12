//
//  UITextFieldSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIKitComponents {
    
    final class UITextFieldInspectableViewModel: HiearchyInspectableElementViewModelProtocol {
        
        enum Property: String, Swift.CaseIterable {
            case text                          = "Text"
            case textColor                     = "Color"
            case fontName                      = "Font Name"
            case fontSize                      = "Font Size"
            case adjustsFontSizeToFitWidth     = "Automatically Adjusts Font"
            case textAlignment                 = "Alignment"
            case placeholder                   = "Placeholder"
            case groupImages                   = "Images"
            case background                    = "Background Image"
            case disabledBackground            = "Disabled Background Image"
            case groupBorder                   = "Border"
            case borderStyle                   = "Border Style"
            case groupClearButton              = "Buttons"
            case clearButton                   = "Clear Button"
            case clearWhenEditingBegins        = "Clear When Editing Begins"
            case groupAdditionalFontOptions    = "Additional Font Options"
            case minFontSize                   = "Min Font Size"
            case groupTextInputTraits          = "Text Input Traits"
            case textContentType               = "Content Type"
            case autocapitalizationType        = "Capitalization"
            case autocorrectionType            = "Correction"
            case smartDashesType               = "Smart Dashes"
            case smartQuotesType               = "Smart Quotes"
            case spellCheckingType             = "Spell Checking"
            case keyboardType                  = "Keyboard Type"
            case keyboardAppearance            = "Keyboard Look"
            case returnKey                     = "Return Key"
            case enablesReturnKeyAutomatically = "Auto-enable Return Key"
            case isSecureTextEntry             = "Secure Text Entry"
        }
        
        let title = "Text Field"
        
        private(set) weak var textField: UITextField?
        
        init?(view: UIView) {
            guard let textField = view as? UITextField else {
                return nil
            }
            
            self.textField = textField
        }
        
        private(set) lazy var properties: [HiearchyInspectableElementProperty] = Property.allCases.compactMap { property in
            guard let textField = textField else {
                return nil
            }
            
            switch property {
                
            case .text:
                return .textField(
                    title: property.rawValue,
                    placeholder: { textField.text.isNilOrEmpty ? property.rawValue : textField.text },
                    value: { textField.text }
                ) { text in
                    textField.text = text
                }
                
            case .textColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { textField.textColor }
                ) { textColor in
                    textField.textColor = textColor
                }
                
            case .fontName:
                return .fontNamePicker(
                    title: property.rawValue,
                    fontProvider: { textField.font }
                ) { font in
                    guard let font = font else {
                        return
                    }
                    
                    textField.font = font
                }
                
            case .fontSize:
                return .fontSizeStepper(
                    title: property.rawValue,
                    fontProvider: { textField.font }
                ) { font in
                    guard let font = font else {
                        return
                    }
                    
                    textField.font = font
                }
                
            case .textAlignment:
                let allCases = NSTextAlignment.allCases.withImages
                
                return .imageButtonGroup(
                    title: property.rawValue,
                    images: allCases.compactMap { $0.image },
                    selectedIndex: { allCases.firstIndex(of: textField.textAlignment) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let textAlignment = allCases[newIndex]
                    
                    textField.textAlignment = textAlignment
                }
                
            case .placeholder:
                return .textField(
                    title: property.rawValue,
                    placeholder: { textField.placeholder.isNilOrEmpty ? property.rawValue : textField.placeholder },
                    value: { textField.placeholder }
                ) { placeholder in
                    textField.placeholder = placeholder
                }
                
            case .groupImages:
                return .group(title: property.rawValue)
                
            case .background:
                return .imagePicker(
                    title: property.rawValue,
                    image: { textField.background }
                ) { background in
                    textField.background = background
                }
                
            case .disabledBackground:
                return .imagePicker(
                    title: property.rawValue,
                    image: { textField.disabledBackground }
                ) { disabledBackground in
                    textField.disabledBackground = disabledBackground
                }
                
            case .groupBorder:
                return .separator(title: property.rawValue)
                
            case .borderStyle:
                let allCases = UITextField.BorderStyle.allCases.withImages
                
                return .imageButtonGroup(
                    title: property.rawValue,
                    axis: .vertical,
                    images: allCases.compactMap { $0.image },
                    selectedIndex: { allCases.firstIndex(of: textField.borderStyle) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let borderStyle = allCases[newIndex]
                    
                    textField.borderStyle = borderStyle
                }
                
            case .groupClearButton:
                return .separator(title: property.rawValue)
                
            case .clearButton:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextField.ViewMode.allCases.map { $0.description },
                    selectedIndex: { UITextField.ViewMode.allCases.firstIndex(of: textField.clearButtonMode) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let clearButtonMode = UITextField.ViewMode.allCases[newIndex]
                    
                    textField.clearButtonMode = clearButtonMode
                }
            
            case .clearWhenEditingBegins:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { textField.clearsOnBeginEditing }
                ) { clearsOnBeginEditing in
                    textField.clearsOnBeginEditing = clearsOnBeginEditing
                }
                
            case .groupAdditionalFontOptions:
                return .separator(title: property.rawValue)
                
            case .minFontSize:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { textField.minimumFontSize },
                    range: { 0...256 },
                    stepValue: { 1 }
                ) { minimumFontSize in
                    textField.minimumFontSize = minimumFontSize
                }
                
            case .adjustsFontSizeToFitWidth:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { textField.adjustsFontSizeToFitWidth }
                ) { adjustsFontSizeToFitWidth in
                    textField.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
                }
                
            case .groupTextInputTraits:
                return .group(title: property.rawValue)
                
            case .textContentType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextContentType.allCases.map { $0.description },
                    selectedIndex: {
                        guard let textContentType = textField.textContentType else {
                            return nil
                        }
                        
                        return UITextContentType.allCases.firstIndex(of: textContentType)
                    }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let textContentType = UITextContentType.allCases[newIndex]
                    
                    textField.textContentType = textContentType
                }
                
            case .autocapitalizationType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextAutocapitalizationType.allCases.map { $0.description },
                    selectedIndex: { UITextAutocapitalizationType.allCases.firstIndex(of: textField.autocapitalizationType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let autocapitalizationType = UITextAutocapitalizationType.allCases[newIndex]
                    
                    textField.autocapitalizationType = autocapitalizationType
                }
                
            case .autocorrectionType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextAutocorrectionType.allCases.map { $0.description },
                    selectedIndex: { UITextAutocorrectionType.allCases.firstIndex(of: textField.autocorrectionType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let autocorrectionType = UITextAutocorrectionType.allCases[newIndex]
                    
                    textField.autocorrectionType = autocorrectionType
                }
                
            case .smartDashesType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextSmartDashesType.allCases.map { $0.description },
                    selectedIndex: { UITextSmartDashesType.allCases.firstIndex(of: textField.smartDashesType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let smartDashesType = UITextSmartDashesType.allCases[newIndex]
                    
                    textField.smartDashesType = smartDashesType
                }
                
            case .smartQuotesType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextSmartQuotesType.allCases.map { $0.description },
                    selectedIndex: { UITextSmartQuotesType.allCases.firstIndex(of: textField.smartQuotesType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let smartQuotesType = UITextSmartQuotesType.allCases[newIndex]
                    
                    textField.smartQuotesType = smartQuotesType
                }
                
            case .spellCheckingType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextSpellCheckingType.allCases.map { $0.description },
                    selectedIndex: { UITextSpellCheckingType.allCases.firstIndex(of: textField.spellCheckingType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let spellCheckingType = UITextSpellCheckingType.allCases[newIndex]
                    
                    textField.spellCheckingType = spellCheckingType
                }
                
            case .keyboardType:
                return .optionsList(
                    title: property.rawValue,
                    options: UIKeyboardType.allCases.map { $0.description },
                    selectedIndex: { UIKeyboardType.allCases.firstIndex(of: textField.keyboardType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let keyboardType = UIKeyboardType.allCases[newIndex]
                    
                    textField.keyboardType = keyboardType
                }
                
            case .keyboardAppearance:
                return .optionsList(
                    title: property.rawValue,
                    options: UIKeyboardAppearance.allCases.map { $0.description },
                    selectedIndex: { UIKeyboardAppearance.allCases.firstIndex(of: textField.keyboardAppearance) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let keyboardAppearance = UIKeyboardAppearance.allCases[newIndex]
                    
                    textField.keyboardAppearance = keyboardAppearance
                }
                
            case .returnKey:
                return .optionsList(
                    title: property.rawValue,
                    options: UIReturnKeyType.allCases.map { $0.description },
                    selectedIndex: { UIReturnKeyType.allCases.firstIndex(of: textField.returnKeyType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let returnKeyType = UIReturnKeyType.allCases[newIndex]
                    
                    textField.returnKeyType = returnKeyType
                }
                
            case .enablesReturnKeyAutomatically:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { textField.enablesReturnKeyAutomatically }
                ) { enablesReturnKeyAutomatically in
                    textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
                }
                
            case .isSecureTextEntry:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { textField.isSecureTextEntry }
                ) { isSecureTextEntry in
                    textField.isSecureTextEntry = isSecureTextEntry
                }
                
            }
            
        }
    }
    
}
