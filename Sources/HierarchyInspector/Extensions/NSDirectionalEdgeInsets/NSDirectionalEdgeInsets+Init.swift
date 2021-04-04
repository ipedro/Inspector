//
//  NSDirectionalEdgeInsets+Init.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

extension NSDirectionalEdgeInsets {
    
    static func allMargins(_ margins: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: margins, leading: margins, bottom: margins, trailing: margins)
    }
    
    static func verticalMargins(_ vertical: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: vertical, leading: .zero, bottom: vertical, trailing: .zero)
    }
    
    static func horizontalMargins(_ horizontal: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: .zero, leading: horizontal, bottom: .zero, trailing: horizontal)
    }
    
    static func margins(horizontal: CGFloat, vertical: CGFloat) -> NSDirectionalEdgeInsets {
        .init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
    
    static func margins(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> NSDirectionalEdgeInsets {
        .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}
