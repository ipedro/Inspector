//
//  UIKeyboardAppearance+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIKeyboardAppearance: CaseIterable {
    
    public typealias AllCases = [UIKeyboardAppearance]
    
    public static let allCases: [UIKeyboardAppearance] = [
        .default,
        .dark,
        .light
    ]
    
}
