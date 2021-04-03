//
//  UIButton.ButtonType+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIButton.ButtonType: CaseIterable {
    
    typealias AllCases = [UIButton.ButtonType]
    
    static let allCases: [UIButton.ButtonType] = {
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            return [
                .custom,
                .system,
                .detailDisclosure,
                .infoLight,
                .infoDark,
                .contactAdd,
                .close
            ]
        }
        #endif
        return [
            .custom,
            .system,
            .detailDisclosure,
            .infoLight,
            .infoDark,
            .contactAdd
        ]
    }()
    
}
