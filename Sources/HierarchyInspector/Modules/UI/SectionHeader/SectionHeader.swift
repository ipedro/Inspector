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
        
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        
        contentView.addArrangedSubview(textLabel)
        
        contentView.directionalLayoutMargins = .margins(horizontal: 30, vertical: 15)
    }
    
    convenience init(_ textStyle: UIFont.TextStyle = .title3, text: String?) {
        self.init(frame: .zero)
        
        self.textStyle = textStyle
        self.text = text
        self.textLabel.font = .preferredFont(forTextStyle: textStyle)
    }
}
