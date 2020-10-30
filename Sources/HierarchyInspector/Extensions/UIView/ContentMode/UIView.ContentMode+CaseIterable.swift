//
//  UIView.ContentMode+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIView.ContentMode: CaseIterable {
    public typealias AllCases = [UIView.ContentMode]
    
    public static var allCases: [UIView.ContentMode] {
        [
            .scaleToFill,
            .scaleAspectFit,
            .scaleAspectFill,
            .redraw,
            .center,
            .top,
            .bottom,
            .left,
            .right,
            .topLeft,
            .topRight,
            .bottomLeft,
            .bottomRight
        ]
    }
}
