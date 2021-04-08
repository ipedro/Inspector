//
//  UILabel+Init.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

extension UILabel {
    
    convenience init(
        _ fontStyle: UIFont.TextStyle,
        _ text: String? = nil,
        textAlignment: NSTextAlignment = .natural,
        textColor: UIColor? = nil,
        numberOfLines: Int = 1
    ) {
        self.init()
        
        self.text = text
        self.font = .preferredFont(forTextStyle: fontStyle)
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        
        if let textColor = textColor {
            self.textColor = textColor
        }
    }
}
