//
//  UIKeyCommand+Convenience.swift
//  HierarhcyInspector
//
//  Created by Pedro on 10.04.21.
//

import UIKit

extension UIKeyCommand {
    
    static let inputTab = "\t"
    
    static let inputReturn = "\r"
    
    static let inputBackspace = "\u{8}"
    
    static let inputDelete = "\u{7F}"
    
    static let inputSpaceBar = " "
    
    convenience init(
        input: String,
        modifierFlags: UIKeyModifierFlags = [],
        action: Selector,
        title: String? = nil
    ) {
        if let discoverabilityTitle = title {
            self.init(input: input, modifierFlags: modifierFlags, action: action, discoverabilityTitle: discoverabilityTitle)
        } else {
            self.init(input: input, modifierFlags: modifierFlags, action: action)
        }
    }
}
