//
//  UITextSmartDashesType+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UITextSmartDashesType: CaseIterable {
    
    typealias AllCases = [UITextSmartDashesType]
    
    public static let allCases: [UITextSmartDashesType] = [
        .default,
        .no,
        .yes
    ]
    
}
