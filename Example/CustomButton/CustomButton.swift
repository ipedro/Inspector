//
//  CustomButton.swift
//  HierarchyInspectorExample
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

final class CustomButton: UIButton {
    
    var animateOnTouch = true
    
    var cornerRadius: CGFloat = 20 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerCurve = .continuous
        
        layer.cornerRadius = cornerRadius
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard animateOnTouch else {
            return
        }
        
        scale(.in, for: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard animateOnTouch else {
            return
        }
        
        scale(.out, for: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event )
        
        guard animateOnTouch else {
            return
        }
        
        scale(.out, for: event)
    }
    
    enum Animation {
        case `in`, out
    }
    
    func scale(_ type: Animation, for event: UIEvent?) {
        switch event?.type {
        case .presses, .touches:
            break
            
        default:
            return
        }
        
        let delay = type == .in ? 0 : 0.15
        
        UIView.animate(withDuration: 0.2, delay: delay, animations: {
            switch type {
            case .in:
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                
            case .out:
                self.transform = .identity
            }
        })
    }
}