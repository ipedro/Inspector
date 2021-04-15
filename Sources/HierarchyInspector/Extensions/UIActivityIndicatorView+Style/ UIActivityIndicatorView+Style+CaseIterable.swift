//
//   UIActivityIndicatorView.Style+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

extension UIActivityIndicatorView.Style: CaseIterable {
    typealias AllCases = [UIActivityIndicatorView.Style]
    
    #if swift(>=5.0)
    static let allCases: [UIActivityIndicatorView.Style] = {
        if #available(iOS 13.0, *) {
            return [
                .medium,
                .large,
                .whiteLarge,
                .white,
                .gray
            ]
        }
        
        return [
            .whiteLarge,
            .white,
            .gray
        ]
    }()
    
    #else
    static let allCases: [UIActivityIndicatorView.Style] = [
        .whiteLarge,
        .white,
        .gray
    ]
    #endif
}
