//
//  UITextAutocorrectionType+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextAutocorrectionType: CaseIterable {
    
    public typealias AllCases = [UITextAutocorrectionType]
    
    public static let allCases: [UITextAutocorrectionType] = [
        .default,
        .no,
        .yes
    ]
}
