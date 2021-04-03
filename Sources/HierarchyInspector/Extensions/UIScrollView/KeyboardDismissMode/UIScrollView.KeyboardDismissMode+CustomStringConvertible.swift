//
//  UIScrollView.KeyboardDismissMode+CustomStringConvertible.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import UIKit

extension UIScrollView.KeyboardDismissMode: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .none:
            return "Do Not Dismiss"
            
        case .onDrag:
            return "Dismiss On Drag"
            
        case .interactive:
            return "Dismiss Interactively"
            
        @unknown default:
            return "\(self) (unsupported)"
        }
    }
    
}

