//
//  UIStackView.Distribution+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIStackView.Distribution: CaseIterable {
    typealias AllCases = [UIStackView.Distribution]
    
    static let allCases: [UIStackView.Distribution] = [
        .fill,
        .fillEqually,
        .fillProportionally,
        .equalSpacing,
        .equalCentering
    ]
}
