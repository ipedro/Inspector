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
        
        contentView.spacing = ElementInspector.configuration.appearance.verticalMargins / 2
        
        contentView.directionalLayoutMargins = .margins(horizontal: 12, vertical: 9) // matches UIStepper
        
        layer.cornerRadius = ElementInspector.configuration.appearance.verticalMargins / 2
        
        setContentHuggingPriority(.required, for: .horizontal)
        
        setContentHuggingPriority(.required, for: .vertical)
        
        backgroundColor = ElementInspector.configuration.appearance.accessoryControlBackgroundColor
    }
}
