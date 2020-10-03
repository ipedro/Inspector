//
//  UIAlertAction+Convenience.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - UIAlertAction Extension

extension UIAlertAction {

    static func separator(_ text: String? = nil) -> UIAlertAction {
        var title: String {
            guard let text = text else {
                return "✻"
            }
            
            return "✻ \(text) ✻"
        }
        
        let action = UIAlertAction(title: title, style: .default, handler: nil)
        
        action.isEnabled = false
        
        return action
    }
    
}
