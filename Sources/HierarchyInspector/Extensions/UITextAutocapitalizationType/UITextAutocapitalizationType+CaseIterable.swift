//
//  UITextAutocapitalizationType+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextAutocapitalizationType: CaseIterable {
    
    typealias AllCases = [UITextAutocapitalizationType]
    
    public static let allCases: [UITextAutocapitalizationType] = [
        .none,
        .words,
        .sentences,
        .allCharacters
    ]
}
