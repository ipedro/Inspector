//
//  SectionHeader.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class SectionHeader: BaseView {
    
    private lazy var textLabel = UILabel(textStyle)
    
    var textStyle: UIFont.TextStyle = .title3 {
        didSet {
            textLabel.font = .preferredFont(forTextStyle: textStyle)
        }
    }
    
    var text: String? {
        get {
            textLabel.text
        }
        set {
            textLabel.text = newValue
        }
    }
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(textLabel)
        
        contentView.directionalLayoutMargins = .margins(horizontal: 30, vertical: 15)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        backgroundColor = superview?.backgroundColor
    }
    
    convenience init(_ textStyle: UIFont.TextStyle = .title3, text: String?, bold: Bool = false) {
        self.init(frame: .zero)
        
        self.textStyle = textStyle
        self.text = text
        
        let font = UIFont.preferredFont(forTextStyle: textStyle)
        
        switch bold {
        case true:
            self.textLabel.font = font.bold()
            
        case false:
            self.textLabel.font = font
        }
        
    }
}
