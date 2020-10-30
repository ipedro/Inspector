//
//  UIScrollView.KeyboardDismissMode+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIScrollView.KeyboardDismissMode: CaseIterable {
    
    public typealias AllCases = [UIScrollView.KeyboardDismissMode]
    
    public static let allCases: [UIScrollView.KeyboardDismissMode] = [
        .none,
        .onDrag,
        .interactive
    ]
    
}
