//
//  UITextView+Init.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

extension UITextView {
    
    convenience init(
        _ fontStyle: UIFont.TextStyle,
        _ text: String? = nil,
        textAlignment: NSTextAlignment = .natural,
        textColor: UIColor? = nil,
        isScrollEnabled: Bool = false,
        isSelectable: Bool = true,
        isEditable: Bool = false
    ) {
        self.init()
        
        self.text = text
        self.font = .preferredFont(forTextStyle: fontStyle)
        self.textAlignment = textAlignment
        self.isScrollEnabled = isScrollEnabled
        self.isSelectable = isSelectable
        self.isEditable = isEditable
        self.backgroundColor = nil
        
        if let textColor = textColor {
            self.textColor = textColor
        }
        
        self.textContainerInset = UIEdgeInsets(
            top: 0,
            left: -textContainer.lineFragmentPadding,
            bottom: 0,
            right: -textContainer.lineFragmentPadding
        )
    }
}
