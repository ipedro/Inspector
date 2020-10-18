//
//  NSTextAlignment+CaseIterable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 16.10.20.
//

import UIKit

extension NSTextAlignment: CaseIterable {
    public typealias AllCases = [NSTextAlignment]
    
    public static let allCases: [NSTextAlignment] = [
        .left,
        .center,
        .right,
        .justified,
        .natural
    ]
}