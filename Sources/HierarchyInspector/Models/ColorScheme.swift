//
//  ColorScheme.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

extension HierarchyInspector {
    public struct ColorScheme {
        public static let `default` = ColorScheme { view in
            switch view {
            case let control as UIControl:
                return control.isEnabled ? .systemPurple : .systemGray
                
            case is UIStackView:
                return .systemBlue
                
            default:
                return .systemTeal
            }
        }
        
        private let closure: (UIView) -> UIColor
        
        public static func colorScheme(_ closure: @escaping (UIView) -> UIColor) -> ColorScheme {
            self.init(closure: closure)
        }
        
        public func color(for view: UIView) -> UIColor {
            closure(view)
        }
    }
}
