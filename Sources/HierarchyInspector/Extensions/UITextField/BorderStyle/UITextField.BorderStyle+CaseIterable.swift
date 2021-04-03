//
//  UITextField.BorderStyle+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextField.BorderStyle: CaseIterable {
    
    typealias AllCases = [UITextField.BorderStyle]
    
    public static let allCases: [UITextField.BorderStyle] = [
        .none,
        .line,
        .bezel,
        .roundedRect
    ]
    
}
