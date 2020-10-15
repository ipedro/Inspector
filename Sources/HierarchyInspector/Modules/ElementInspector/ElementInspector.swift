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
        
        lazy var tintColor: UIColor = .systemPurple
        
        lazy var textColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .label
            }
            #endif
            
            return .darkText
        }()
        
        lazy var secondaryTextColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            }
            #endif
            
            return UIColor.darkText.withAlphaComponent(0.6)
        }()
        
        
        lazy var tertiaryTextColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .tertiaryLabel
            }
            #endif
            
            return UIColor.darkText.withAlphaComponent(0.3)
        }()
        
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
        
        var panelHighlightBackgroundColor: UIColor = {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                return .tertiarySystemBackground
            }
            #endif
            
            return .white
        }()
    }
    
    static var appearance = Appearance()
}
