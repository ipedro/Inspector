//
//  UITextField.ViewMode+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextField.ViewMode: CaseIterable {
    typealias AllCases = [UITextField.ViewMode]
    
    public static let allCases: [UITextField.ViewMode] = [
        .never,
        .whileEditing,
        .unlessEditing,
        .always,
    ]
}
