//
//  UIStackView.Alignment+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIStackView.Alignment: CaseIterable {
    typealias AllCases = [UIStackView.Alignment]
    
    public static let allCases: [UIStackView.Alignment] = [
        .fill,
        .leading,
        .firstBaseline,
        .center,
        .trailing,
        .lastBaseline
    ]
}
