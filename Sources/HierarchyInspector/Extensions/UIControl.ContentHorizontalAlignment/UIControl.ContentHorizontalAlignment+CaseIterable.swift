//
//  UIControl.ContentHorizontalAlignment+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIControl.ContentHorizontalAlignment: CaseIterable {
    public typealias AllCases = [UIControl.ContentHorizontalAlignment]
    
    public static let allCases: [UIControl.ContentHorizontalAlignment] = [
        .leading,
        .left,
        .center,
        .trailing,
        .right,
        .fill
    ]
}
