//
//  UIStackView+Convenience.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 06.10.20.
//

import UIKit

extension UIStackView {
    
    convenience init(axis: NSLayoutConstraint.Axis, arrangedSubviews: [UIView] = [], spacing: CGFloat = .zero, margins: NSDirectionalEdgeInsets = .zero) {
        self.init(arrangedSubviews: arrangedSubviews)
        
        self.isLayoutMarginsRelativeArrangement = true
        
        self.axis = axis
        self.spacing = spacing
        self.directionalLayoutMargins = margins
    }
}
