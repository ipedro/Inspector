//  Copyright (c) 2021 Pedro Almeida
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

extension SectionHeader {
    static func attributesInspectorHeader(title: String? = nil) -> SectionHeader {
        SectionHeader(
            .callout,
            text: title,
            withTraits: .traitBold,
            margins: NSDirectionalEdgeInsets(
                vertical: ElementInspector.appearance.verticalMargins / 2
            )
        )
    }
    
    static func attributesInspectorGroup(title: String? = nil) -> SectionHeader {
        SectionHeader(
            .footnote,
            text: title,
            margins: NSDirectionalEdgeInsets(
                top: ElementInspector.appearance.horizontalMargins,
                bottom: ElementInspector.appearance.verticalMargins
            )
        ).then {
            $0.alpha = 1 / 3
        }
    }
}

final class SectionHeader: BaseView {
    
    private(set) lazy var textLabel = UILabel(
        .textColor(ElementInspector.appearance.textColor),
        .numberOfLines(.zero),
        .adjustsFontSizeToFitWidth(true),
        .preferredMaxLayoutWidth(200)
    )
    
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