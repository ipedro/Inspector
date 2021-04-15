//
//  UIScrollView.KeyboardDismissMode+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIScrollView.KeyboardDismissMode: CaseIterable {
    
    typealias AllCases = [UIScrollView.KeyboardDismissMode]
    
    static let allCases: [UIScrollView.KeyboardDismissMode] = [
        .none,
        .onDrag,
        .interactive
    ]
    
}
