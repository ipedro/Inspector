//
//  UIKeyboardType+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIKeyboardType: CustomStringConvertible {
    
    var description: String {
        switch self {
        
        case .default:
            return "Default"
            
        case .asciiCapable:
            return "Ascii Capable"
            
        case .numbersAndPunctuation:
            return "Numbers And Punctuation"
            
        case .URL:
            return "URL"
            
        case .numberPad:
            return "Number Pad"
            
        case .phonePad:
            return "Phone Pad"
            
        case .namePhonePad:
            return "Name Phone Pad"
            
        case .emailAddress:
            return "Email Address"
            
        case .decimalPad:
            return "Decimal Pad"
            
        case .twitter:
            return "Twitter"
            
        case .webSearch:
            return "Web Search"
            
        case .asciiCapableNumberPad:
            return "Ascii Capable Number Pad"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
        
    }
    
}
