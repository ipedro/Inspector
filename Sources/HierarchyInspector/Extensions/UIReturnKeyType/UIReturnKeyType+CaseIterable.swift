//
//  UIReturnKeyType+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIReturnKeyType: CaseIterable {
    typealias AllCases = [UIReturnKeyType]
    
    static let allCases: [UIReturnKeyType] = [
        .default,
        .go,
        .google,
        .join,
        .next,
        .route,
        .search,
        .send,
        .yahoo,
        .done,
        .emergencyCall,
        .continue,
    ]
}
