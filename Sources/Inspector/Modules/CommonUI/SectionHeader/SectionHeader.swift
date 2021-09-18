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
            title: title,
            titleFont: .init(.body, .traitBold),
            margins: .init(vertical: ElementInspector.appearance.verticalMargins / 2)
        )
    }

    static func attributesInspectorGroup(title: String? = nil) -> SectionHeader {
        SectionHeader(
            title: title,
            titleFont: .footnote,
            margins: .init(
                top: ElementInspector.appearance.horizontalMargins,
                bottom: ElementInspector.appearance.verticalMargins
            )
        ).then {
            $0.alpha = $0.colorStyle.disabledAlpha
        }
    }
}

final class SectionHeader: BaseView {
    var titleAlignment: NSTextAlignment {
        get { titleLabel.textAlignment }
        set { titleLabel.textAlignment = newValue }
    }

    private lazy var titleLabel = UILabel(
        .textColor(colorStyle.textColor)
    ).then {
        $0.font = titleFont.font()
        $0.isHidden = $0.text?.isEmpty != false
    }

    var subtitleAlignment: NSTextAlignment {
        get { subtitleLabel.textAlignment }
        set { subtitleLabel.textAlignment = newValue }
    }

    private lazy var subtitleLabel = UILabel(
        .textColor(colorStyle.secondaryTextColor)
    ).then {
        $0.font = subtitleFont.font()
        $0.isHidden = $0.text?.isEmpty != false
    }

    private lazy var textStackView = UIStackView.vertical(
        .arrangedSubviews(titleLabel, subtitleLabel),
        .spacing(ElementInspector.appearance.verticalMargins / 2)
    ).then {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.clipsToBounds = false
    }

    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
            titleLabel.isHidden = newValue?.isEmpty != false
        }
    }

    var subtitle: String? {
        get {
            subtitleLabel.text
        }
        set {
            subtitleLabel.text = newValue
            subtitleLabel.isHidden = newValue?.isEmpty != false
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

    struct FontOptions {
        var style: UIFont.TextStyle
        var traits: UIFontDescriptor.SymbolicTraits = .traitUIOptimized

        init(_ style: UIFont.TextStyle, _ traits: UIFontDescriptor.SymbolicTraits = .traitUIOptimized) {
            self.style = style
            self.traits = traits
        }
        func font() -> UIFont {
            .preferredFont(forTextStyle: style, with: traits.union(.traitUIOptimized))
        }

        // MARK: - Convenience Inits

        static let largeTitle: Self = .init(.largeTitle)
        static let title1: Self = .init(.title1)
        static let title2: Self = .init(.title2)
        static let title3: Self = .init(.title3)
        static let headline: Self = .init(.headline)
        static let subheadline: Self = .init(.subheadline)
        static let body: Self = .init(.body)
        static let callout: Self = .init(.callout)
        static let footnote: Self = .init(.footnote)
        static let caption1: Self = .init(.caption1)
        static let caption2: Self = .init(.caption2)

    }

    var margins: NSDirectionalEdgeInsets {
        get { contentView.directionalLayoutMargins }
        set { contentView.directionalLayoutMargins = newValue }
    }

    var titleFont: FontOptions {
        didSet {
            titleLabel.font = titleFont.font()
        }
    }

    var subtitleFont: FontOptions {
        didSet {
            subtitleLabel.font = subtitleFont.font()
        }
    }

    override func setup() {
        super.setup()
        contentView.axis = .horizontal
        contentView.addArrangedSubview(textStackView)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        backgroundColor = superview?.backgroundColor
    }

    init(
        title: String? = nil,
        titleFont: FontOptions = .title3,
        subtitle: String? = nil,
        subtitleFont: FontOptions = .body,
        margins: NSDirectionalEdgeInsets = ElementInspector.appearance.directionalInsets
    ) {
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont

        super.init(frame: .zero)

        self.title = title
        self.subtitle = subtitle
        self.margins = margins
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init?(coder:) not implemented")
    }
}
