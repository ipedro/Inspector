//
//  HierarchyInspector.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

typealias ColorScheme = HierarchyInspector.ColorScheme

typealias Filter = HierarchyInspector.Filter

public enum HierarchyInspector {
    
    public typealias Filter = (UIView) -> Bool
    
    public typealias ColorScheme = (UIView) -> UIColor
    
    static var configuration = Configuration()
    
    public static let defaultColorScheme: ColorScheme = {
        switch $0 {
        case let control as UIControl:
            return control.isEnabled ? .systemPurple : .systemGray
            
        case is UIStackView:
            return .systemBlue
            
        default:
            return .systemTeal
        }
    }
}
