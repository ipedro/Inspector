//
//  ViewHierarchyColorScheme.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public struct ViewHierarchyColorScheme {
    public static let `default` = ViewHierarchyColorScheme { view in
        guard view.isUserInteractionEnabled == true else {
            return .systemGray
        }
        
        switch view {
        case let control as UIControl:
            return control.isEnabled ? .systemPurple : .systemGray
            
        case is UIStackView:
            return .systemBlue
            
        case is UIWindow:
            return .darkGray
            
        case is UITableView,
             is UICollectionView:
            return .systemYellow
            
        case is UITableViewCell,
             is UICollectionViewCell:
            return .systemOrange
            
        default:
            return .systemTeal
        }
    }
    
    private let closure: (UIView) -> UIColor
    
    public static func colorScheme(_ closure: @escaping (UIView) -> UIColor) -> ViewHierarchyColorScheme {
        self.init(closure: closure)
    }
    
    public func color(for view: UIView) -> UIColor {
        closure(view)
    }
}
