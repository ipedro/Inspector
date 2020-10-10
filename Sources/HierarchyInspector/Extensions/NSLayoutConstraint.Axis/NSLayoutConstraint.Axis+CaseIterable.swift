//
//  NSLayoutConstraint.Axis+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension NSLayoutConstraint.Axis: CaseIterable {
    public typealias AllCases = [NSLayoutConstraint.Axis]
    
    public static let allCases: [NSLayoutConstraint.Axis] = [
        .horizontal,
        vertical
    ]
}
