//
//  ElementInspector.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

enum ElementInspector {
    
    struct Appearance {
        
        let horizontalMargins: CGFloat = 26
        
        let verticalMargins: CGFloat = 13
        
        var margins: NSDirectionalEdgeInsets {
            .margins(
                horizontal: ElementInspector.appearance.horizontalMargins,
                vertical: ElementInspector.appearance.verticalMargins
            )
        }
        
    }
    
    static var appearance = Appearance()
}
