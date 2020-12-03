//
//  UITextViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension AttributesInspectorSection {
    
    final class UITextViewSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        enum Property: String, CaseIterable {
            case text                               = "Text"
            case textColor                          = "Color"
            case fontName                           = "Font Name"
            case fontSize                           = "Font Size"
            case adjustsFontForContentSizeCategory  = "Automatically Adjusts Font"
            case textAlignment                      = "Alignment"
            case groupBehavior                      = "Behavior"
            case isEditable                         = "Editable"
            case isSelectable                       = "Selectable"
            case groupDataDetectors                 = "Data Detectors"
            case dataDetectorPhoneNumber            = "Phone Number"
            case dataDetectorLink                   = "Link"
            case dataDetectorAddress                = "Address"
            case dataDetectorCalendarEvent          = "Calendar Event"
            case dataDetectorShipmentTrackingNumber = "Shipment Tracking Number"
            case dataDetectorFlightNumber           = "Flight Number"
            case dataDetectorLookupSuggestion       = "Lookup Suggestion"
            case groupTextInputTraits               = "Text Input Traits"
            case textContentType                    = "Content Type"
            case autocapitalizationType             = "Capitalization"
            case autocorrectionType                 = "Correction"
            case smartDashesType                    = "Smart Dashes"
            case smartQuotesType                    = "Smart Quotes"
            case spellCheckingType                  = "Spell Checking"
            case keyboardType                       = "Keyboard Type"
            case keyboardAppearance                 = "Keyboard Look"
            case returnKey                          = "Return Key"
            case enablesReturnKeyAutomatically      = "Auto-enable Return Key"
            case isSecureTextEntry                  = "Secure Text Entry"
        }
        
        let title = "Text View"
        
        private(set) weak var textView: UITextView?
        
        init?(view: UIView) {
            guard let textView = view as? UITextView else {
                return nil
            }
            
            self.textView = textView
        }
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap { property in
            guard let textView = textView else {
                return nil
            }
            
            switch property {
                
            #warning("TODO: create text view control")
            case .text:
                return .textField(
                    title: property.rawValue,
                    value: { textView.text },
                    placeholder: { textView.text.isNilOrEmpty ? property.rawValue : textView.text }
                ) { text in
                    textView.text = text
                }
                
            case .textColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { textView.textColor }
                ) { textColor in
                    textView.textColor = textColor
                }
                
            case .fontName:
                return .fontNamePicker(
                    title: property.rawValue,
                    fontProvider: { textView.font }
                ) { font in
                    guard let font = font else {
                        return
                    }
                    
                    textView.font = font
                }
                
            case .fontSize:
                return .fontSizeStepper(
                    title: property.rawValue,
                    fontProvider: { textView.font }
                ) { font in
                    guard let font = font else {
                        return
                    }
                    
                    textView.font = font
                }
                
            case .adjustsFontForContentSizeCategory:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { textView.adjustsFontForContentSizeCategory }
                ) { adjustsFontForContentSizeCategory in
                    textView.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
                }
            
            case .textAlignment:
                return .segmentedControl(
                    title: property.rawValue,
                    options: NSTextAlignment.allCases,
                    selectedIndex: { NSTextAlignment.allCases.firstIndex(of: textView.textAlignment) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let textAlignment = NSTextAlignment.allCases[newIndex]
                    
                    textView.textAlignment = textAlignment
                }
                
            case .groupBehavior:
                return .group(title: property.rawValue)
                
            case .isEditable:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { textView.isEditable }
                ) { isEditable in
                    textView.isEditable = isEditable
                }
                
            case .isSelectable:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { textView.isSelectable }
                ) { isSelectable in
                    textView.isSelectable = isSelectable
                }
                
            case .groupDataDetectors:
                return .group(title: property.rawValue)
                
            case .dataDetectorPhoneNumber:
                return .dataDetectorType(textView: textView, dataDetectorType: .phoneNumber)
                
            case .dataDetectorLink:
                return .dataDetectorType(textView: textView, dataDetectorType: .link)
                
            case .dataDetectorAddress:
                return .dataDetectorType(textView: textView, dataDetectorType: .address)
                
            case .dataDetectorCalendarEvent:
                return .dataDetectorType(textView: textView, dataDetectorType: .calendarEvent)
                
            case .dataDetectorShipmentTrackingNumber:
                return .dataDetectorType(textView: textView, dataDetectorType: .shipmentTrackingNumber)
                
            case .dataDetectorFlightNumber:
                return .dataDetectorType(textView: textView, dataDetectorType: .flightNumber)
                
            case .dataDetectorLookupSuggestion:
                return .dataDetectorType(textView: textView, dataDetectorType: .lookupSuggestion)
                
            case .groupTextInputTraits:
                return .group(title: property.rawValue)
                
            case .textContentType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextContentType.allCases,
                    selectedIndex: {
                        guard let textContentType = textView.textContentType else {
                            return nil
                        }
                        
                        return UITextContentType.allCases.firstIndex(of: textContentType)
                    }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let textContentType = UITextContentType.allCases[newIndex]
                    
                    textView.textContentType = textContentType
                }
                
            case .autocapitalizationType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextAutocapitalizationType.allCases,
                    selectedIndex: { UITextAutocapitalizationType.allCases.firstIndex(of: textView.autocapitalizationType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let autocapitalizationType = UITextAutocapitalizationType.allCases[newIndex]
                    
                    textView.autocapitalizationType = autocapitalizationType
                }
                
            case .autocorrectionType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextAutocorrectionType.allCases,
                    selectedIndex: { UITextAutocorrectionType.allCases.firstIndex(of: textView.autocorrectionType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let autocorrectionType = UITextAutocorrectionType.allCases[newIndex]
                    
                    textView.autocorrectionType = autocorrectionType
                }
                
            case .smartDashesType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextSmartDashesType.allCases,
                    selectedIndex: { UITextSmartDashesType.allCases.firstIndex(of: textView.smartDashesType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let smartDashesType = UITextSmartDashesType.allCases[newIndex]
                    
                    textView.smartDashesType = smartDashesType
                }
                
            case .smartQuotesType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextSmartQuotesType.allCases,
                    selectedIndex: { UITextSmartQuotesType.allCases.firstIndex(of: textView.smartQuotesType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let smartQuotesType = UITextSmartQuotesType.allCases[newIndex]
                    
                    textView.smartQuotesType = smartQuotesType
                }
                
            case .spellCheckingType:
                return .optionsList(
                    title: property.rawValue,
                    options: UITextSpellCheckingType.allCases,
                    selectedIndex: { UITextSpellCheckingType.allCases.firstIndex(of: textView.spellCheckingType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let spellCheckingType = UITextSpellCheckingType.allCases[newIndex]
                    
                    textView.spellCheckingType = spellCheckingType
                }
                
            case .keyboardType:
                return .optionsList(
                    title: property.rawValue,
                    options: UIKeyboardType.allCases,
                    selectedIndex: { UIKeyboardType.allCases.firstIndex(of: textView.keyboardType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let keyboardType = UIKeyboardType.allCases[newIndex]
                    
                    textView.keyboardType = keyboardType
                }
                
            case .keyboardAppearance:
                return .optionsList(
                    title: property.rawValue,
                    options: UIKeyboardAppearance.allCases,
                    selectedIndex: { UIKeyboardAppearance.allCases.firstIndex(of: textView.keyboardAppearance) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let keyboardAppearance = UIKeyboardAppearance.allCases[newIndex]
                    
                    textView.keyboardAppearance = keyboardAppearance
                }
                
            case .returnKey:
                return .optionsList(
                    title: property.rawValue,
                    options: UIReturnKeyType.allCases,
                    selectedIndex: { UIReturnKeyType.allCases.firstIndex(of: textView.returnKeyType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let returnKeyType = UIReturnKeyType.allCases[newIndex]
                    
                    textView.returnKeyType = returnKeyType
                }
                
            case .enablesReturnKeyAutomatically:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { textView.enablesReturnKeyAutomatically }
                ) { enablesReturnKeyAutomatically in
                    textView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
                }
                
            case .isSecureTextEntry:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { textView.isSecureTextEntry }
                ) { isSecureTextEntry in
                    textView.isSecureTextEntry = isSecureTextEntry
                }
                
            }
            
        }
    }
    
}
