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
    
    private lazy var textLabel = UILabel(
        .textColor(ElementInspector.appearance.textColor),
        .numberOfLines(.zero),
        .adjustsFontSizeToFitWidth(true),
        .preferredMaxLayoutWidth(200),
        .minimumScaleFactor(0.5)
    )
    
    var text: String? {
        get {
            textLabel.text
        }
        set {
            textLabel.text = newValue
        }
    }

    var accessoryView: UIView? {
        didSet {
            if let accessoryView = accessoryView {
                contentView.addArrangedSubview(accessoryView)
            }
            if let oldValue = oldValue {
                oldValue.removeFromSuperview()
            }
        }
    }

    var textStyle: UIFont.TextStyle {
        didSet {
            textLabel.font = font()
        }
    }

    var traits: UIFontDescriptor.SymbolicTraits {
        didSet {
            textLabel.font = font()
        }
    }

    func font() -> UIFont {
        .preferredFont(forTextStyle: textStyle, with: traits.union(.traitUIOptimized))
    }

    override func setup() {
        super.setup()
        contentView.axis = .horizontal
        contentView.addArrangedSubview(textLabel)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        backgroundColor = superview?.backgroundColor
    }
    
    init(
        _ textStyle: UIFont.TextStyle = .title3,
        text: String?,
        withTraits traits: UIFontDescriptor.SymbolicTraits = .traitUIOptimized,
        margins: NSDirectionalEdgeInsets = ElementInspector.appearance.directionalInsets
    ) {
        self.textStyle = textStyle
        self.traits = traits.union(.traitUIOptimized)

        super.init(frame: .zero)

        self.text = text
        self.contentView.directionalLayoutMargins = margins
        self.textLabel.font = font()
    }

    required init?(coder: NSCoder) {
        fatalError("init?(coder:) not implemented")
    }
}
