//
//  ViewInspectorControlAccessoryControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

final class ViewInspectorControlAccessoryControl: BaseControl {
    
    override func setup() {
        super.setup()
        
        animateOnTouch = true
        
        contentView.axis = .horizontal
        
        contentView.spacing = ElementInspector.appearance.verticalMargins / 2
        
        contentView.directionalLayoutMargins = .margins(horizontal: 12, vertical: 9) // matches UIStepper
        
        layer.cornerRadius = ElementInspector.appearance.verticalMargins / 2
        
        #warning("TODO: move to theme")
        backgroundColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label.withAlphaComponent(0.085)
            }
            
            return UIColor.black.withAlphaComponent(0.085)
        }()
    }
}
