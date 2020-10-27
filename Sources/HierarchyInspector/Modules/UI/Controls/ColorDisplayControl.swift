//
//  ColorDisplayControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

final class ColorDisplayControl: BaseControl {
    
    var color: UIColor? {
        didSet {
            colorBackgroundView.backgroundColor = color
        }
    }
    
    private lazy var colorBackgroundView = UIView().then {
        $0.isUserInteractionEnabled = false
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = ElementInspector.configuration.appearance.tertiaryTextColor
        
        layer.cornerRadius = 5
        
        layer.masksToBounds = true
        
        installView(colorBackgroundView)
    }
    
    override func draw(_ rect: CGRect) {
        IconKit.drawColorGrid(frame: bounds, resizing: .aspectFill)
    }
}
