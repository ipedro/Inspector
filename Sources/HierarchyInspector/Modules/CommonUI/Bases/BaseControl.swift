//
//  BaseControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

class BaseControl: UIControl, InternalViewProtocol {
    
    open var animateOnTouch: Bool = false
    
    let spacing = ElementInspector.appearance.verticalMargins
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    open func setup() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var contentView = UIStackView(
        axis: .horizontal,
        spacing: spacing
    ).then {
        installView($0, priority: .required)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard isEnabled, animateOnTouch else {
            return
        }
        
        scale(.in, for: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard isEnabled, animateOnTouch else {
            return
        }
        
        scale(.out, for: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event )
        
        guard isEnabled, animateOnTouch else {
            return
        }
        
        scale(.out, for: event)
    }
    
}
