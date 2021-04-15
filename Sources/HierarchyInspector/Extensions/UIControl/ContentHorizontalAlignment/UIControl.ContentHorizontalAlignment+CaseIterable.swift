//
//  UIControl.ContentHorizontalAlignment+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIControl.ContentHorizontalAlignment: CaseIterable {
    typealias AllCases = [UIControl.ContentHorizontalAlignment]
    
    static let allCases: [UIControl.ContentHorizontalAlignment] = [
        .leading,
        .left,
        .center,
        .trailing,
        .right,
        .fill
    ]
}
