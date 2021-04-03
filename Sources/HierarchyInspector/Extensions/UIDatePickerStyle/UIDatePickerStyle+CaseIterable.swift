//
//  UIDatePickerStyle+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

@available(iOS 13.4, *)
extension UIDatePickerStyle: CaseIterable {
    typealias AllCases = [UIDatePickerStyle]
    
    static let allCases: [UIDatePickerStyle] = {
        #if swift(>=5.3)
        if #available(iOS 14.0, *) {
            return [
                .automatic,
                .wheels,
                .compact,
                .inline
            ]
        }
        #endif
        return [
            .automatic,
            .wheels,
            .compact
        ]
    }()
}
