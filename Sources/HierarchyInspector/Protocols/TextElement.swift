//
//  TextElement.swift
//  
//
//  Created by Pedro Almeida on 25.04.21.
//

import UIKit

protocol TextElement: UIView {
    var content: String? { get }
}

extension UILabel: TextElement {
    var content: String? { text?.trimmed }
}

extension UITextView: TextElement {
    var content: String? { text?.trimmed }
}

extension UITextField: TextElement {
    var content: String? { text?.trimmed }
}
