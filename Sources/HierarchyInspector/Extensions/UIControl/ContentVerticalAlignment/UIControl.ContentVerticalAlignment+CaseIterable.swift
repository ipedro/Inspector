//
//  UIControl.ContentVerticalAlignment+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIControl.ContentVerticalAlignment: CaseIterable {
    typealias AllCases = [UIControl.ContentVerticalAlignment]
    
    public static let allCases: [UIControl.ContentVerticalAlignment] = [
        .top,
        .center,
        .bottom,
        .fill
    ]
}
