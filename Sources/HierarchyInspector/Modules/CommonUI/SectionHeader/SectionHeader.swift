//
//  SectionHeader.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

extension SectionHeader {
    static func attributesInspectorHeader(title: String? = nil) -> SectionHeader {
        SectionHeader(
            .callout,
            text: title,
            withTraits: .traitBold,
            margins: .margins(
                horizontal: .zero,
                vertical: ElementInspector.appearance.verticalMargins / 2
            )
        )
    }
    
    static func attributesInspectorGroup(title: String? = nil) -> SectionHeader {
        SectionHeader(
            .footnote,
            text: title,
            margins: .margins(
                top: ElementInspector.appearance.horizontalMargins,
                bottom: ElementInspector.appearance.verticalMargins
            )
        ).then {
            $0.alpha = 1 / 3
        }
    }
}

final class SectionHeader: BaseView {
    
    private(set) lazy var textLabel = UILabel().then {
        $0.textColor = ElementInspector.appearance.textColor
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
        margins: NSDirectionalEdgeInsets = ElementInspector.appearance.directionalInsets
    ) {
        self.init(frame: .zero)
        
        self.text = text
        
        self.contentView.directionalLayoutMargins = margins
        
        guard let traits = traits else {
            textLabel.font = .preferredFont(forTextStyle: textStyle)
            return
        }
        
        textLabel.font = .preferredFont(forTextStyle: textStyle, with: traits)
    }
}
