//
//  UIDatePickerStyle+Extensions.swift
//  HierarchyInspectorExample
//
//  Created by Pedro on 12.04.21.
//

import UIKit

// MARK: - CaseIterable

extension UIDatePickerStyle: CaseIterable {
    public typealias AllCases = [UIDatePickerStyle]
    
    public static let allCases: [UIDatePickerStyle] = [
        .automatic,
        .wheels,
        .compact,
        .inline
    ]
}

// MARK: - CustomStringConvertible

extension UIDatePickerStyle: CustomStringConvertible {
    
    public var description: String {
        switch self {
        
        case .automatic:
            return "Automatic"
            
        case .wheels:
            return "Wheels"
        
        case .compact:
            return "Compact"
        
        case .inline:
            return "Inline"
            
        @unknown default:
            return "Unknown"
            
        }
    }
    
}
