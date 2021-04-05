//
//  UISwitch.Style+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 15.10.20.
//

import UIKit

#if swift(>=5.3)
@available(iOS 14.0, *)
extension UISwitch.Style: CaseIterable {
    typealias AllCases = [UISwitch.Style]
    
    public static let allCases: [UISwitch.Style] = [
        .automatic,
        .checkbox,
        .sliding
    ]
}
#endif

