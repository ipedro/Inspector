//
//  SectionHeader.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class SectionHeader: BaseView {
    
    private(set) lazy var textLabel = UILabel().then {
        $0.textColor = ElementInspector.configuration.appearance.textColor
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.preferredMaxLayoutWidth = 200
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
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        backgroundColor = superview?.backgroundColor
    }
    
    convenience init(
        _ textStyle: UIFont.TextStyle = .title3,
        text: String?,
        withTraits traits: UIFontDescriptor.SymbolicTraits? = nil,
        margins: NSDirectionalEdgeInsets = ElementInspector.configuration.appearance.margins
    ) {
        self.init(frame: .zero)
        
        self.text = text
        
        self.contentView.directionalLayoutMargins = margins
        
        let font = UIFont.preferredFont(forTextStyle: textStyle)
        
        guard let traits = traits else {
            textLabel.font = font
            return
        }
        
        textLabel.font = font.withTraits(traits: traits)
    }
}
