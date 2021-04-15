//
//  UIView+HightlightView.swift
//  
//
//  Created by Pedro on 15.04.21.
//

import UIKit

extension UIView {
    
    var hightlightView: HighlightView? {
        subviews.compactMap { $0 as? HighlightView }.first
    }
    
}
