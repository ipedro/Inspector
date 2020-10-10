//
//  UIControl.ContentVerticalAlignment+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIControl.ContentVerticalAlignment: CaseIterable {
    public typealias AllCases = [UIControl.ContentVerticalAlignment]
    
    public static let allCases: [UIControl.ContentVerticalAlignment] = [
        .center,
        .top,
        .bottom,
        .fill
    ]
}
