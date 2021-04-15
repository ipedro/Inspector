//
//  UIKeyboardType+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIKeyboardType: CaseIterable {
    
    typealias AllCases = [UIKeyboardType]
    
    static let allCases: [UIKeyboardType] = [
        .default,
        .asciiCapable,
        .numbersAndPunctuation,
        .URL,
        .numberPad,
        .phonePad,
        .namePhonePad,
        .emailAddress,
        .decimalPad,
        .twitter,
        .webSearch,
        .asciiCapableNumberPad
    ]
    
}
