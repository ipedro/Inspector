//
//  HierarchyInspectorView+Animation.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.04.21.
//

import UIKit

extension HierarchyInspectorView {
    enum Animation {
        case `in`, out
        
        private var scale: CGAffineTransform { CGAffineTransform(scaleX: 1.1, y: 1.04) }
        
        var damping: CGFloat { 0.84 }
        
        var velocity: CGFloat { .zero }
        
        var options: UIView.AnimationOptions { [.allowUserInteraction, .beginFromCurrentState] }
        
        var startTransform: CGAffineTransform {
            switch self {
            case .in:
                return scale
                
            case .out:
                return .identity
            }
        }
        
        var endTransform: CGAffineTransform {
                switch self {
            case .in:
                return .identity
                
            case .out:
                return scale
            }
        }
    }
}
