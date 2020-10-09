//
//  UILabel+Init.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

extension UILabel {
    
    convenience init(_ fontStyle: UIFont.TextStyle, text: String? = nil, textAlignment: NSTextAlignment = .natural) {
        self.init()
        
        self.text = text
        self.font = .preferredFont(forTextStyle: fontStyle)
        self.textAlignment = textAlignment
    }
}
