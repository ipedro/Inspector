//
//  NSDirectionalEdgeInsets+Init.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

extension NSDirectionalEdgeInsets {
    
    static func margins(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> NSDirectionalEdgeInsets {
    
        NSDirectionalEdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
        
    }
    
}
