//
//  UISemanticContentAttribute+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UISemanticContentAttribute: CaseIterable {
    typealias AllCases = [UISemanticContentAttribute]
    
    static let allCases: [UISemanticContentAttribute] = [
        .unspecified,
        .playback,
        .spatial,
        .forceLeftToRight,
        .forceRightToLeft
    ]
}
