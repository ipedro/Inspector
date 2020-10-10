//
//  UISemanticContentAttribute+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UISemanticContentAttribute: CaseIterable {
    public typealias AllCases = [UISemanticContentAttribute]
    
    public static var allCases: [UISemanticContentAttribute] {
        [
            .unspecified,
            .playback,
            .spatial,
            .forceLeftToRight,
            .forceRightToLeft
        ]
    }
}
