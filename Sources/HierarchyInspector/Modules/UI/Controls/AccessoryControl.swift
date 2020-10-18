//
//  AccessoryControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

final class AccessoryControl: BaseControl {
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.5
        }
    }
    
    override func setup() {
        super.setup()
        
        animateOnTouch = true
        
        contentView.axis = .horizontal
        
        contentView.spacing = ElementInspector.appearance.verticalMargins / 2
        
        contentView.directionalLayoutMargins = .margins(horizontal: 12, vertical: 9) // matches UIStepper
        
        layer.cornerRadius = ElementInspector.appearance.verticalMargins / 2
        
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        
        #warning("TODO: move to theme")
        backgroundColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label.withAlphaComponent(0.085)
            }
            
            return UIColor.black.withAlphaComponent(0.085)
        }()
    }
}