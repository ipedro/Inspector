//
//  UITextSpellCheckingType+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextSpellCheckingType: CaseIterable {
    public typealias AllCases = [UITextSpellCheckingType]
    
    public static let allCases: [UITextSpellCheckingType] = [
        .default,
        .no,
        .yes
    ]
}
