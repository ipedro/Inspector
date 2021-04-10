//
//  UIEdgeInsets+Convenience.swift
//  HierarhcyInspector
//
//  Created by Pedro on 10.04.21.
//

import UIKit

extension UIEdgeInsets {
    
    static func insets(top: CGFloat = .zero, left: CGFloat = .zero, bottom: CGFloat = .zero, right: CGFloat = .zero) -> UIEdgeInsets {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
    
    var verticalInsets: CGFloat { top + bottom }
}
