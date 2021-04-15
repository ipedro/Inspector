//
//  UITextSmartQuotesType+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextSmartQuotesType: CaseIterable {
    typealias AllCases = [UITextSmartQuotesType]
    
    static let allCases: [UITextSmartQuotesType] = [
        .default,
        .no,
        .yes
    ]
}
