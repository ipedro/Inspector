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
        
        var panelBackgroundColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .secondarySystemBackground
            }
            #endif
            
            return .groupTableViewBackground
        }()
    }
    
    static var appearance = Appearance()
}
