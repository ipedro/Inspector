//
//  UIStackView.Distribution+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIStackView.Distribution: CaseIterable {
    public typealias AllCases = [UIStackView.Distribution]
    
    public static let allCases: [UIStackView.Distribution] = [
        .fill,
        .fillEqually,
        .fillProportionally,
        .equalSpacing,
        .equalCentering
    ]
}
