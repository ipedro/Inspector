//
//  UIScrollView.IndicatorStyle+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIScrollView.IndicatorStyle: CaseIterable {
    
    typealias AllCases = [UIScrollView.IndicatorStyle]
    
    public static let allCases: [UIScrollView.IndicatorStyle] = [
        .default,
        .black,
        .white
    ]
    
}
