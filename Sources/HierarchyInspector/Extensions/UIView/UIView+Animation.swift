//
//  UIView+Animation.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

extension UIView {
    
    enum AnimationDirection {
        case `in`, out
    }

    func scale(_ type: AnimationDirection, for event: UIEvent?) {
        switch event?.type {
        case .presses, .touches:
            break
            
        default:
            return
        }
        
        let delay = type == .in ? 0 : 0.15
        
        UIView.animate(
            withDuration: ElementInspector.configuration.animationDuration,
            delay: delay,
            options: [.curveEaseInOut, .beginFromCurrentState],
            animations: {
                switch type {
                case .in:
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    
                case .out:
                    self.transform = .identity
                }
            }
        )
    }

}
