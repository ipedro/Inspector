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

class BaseFormControl: BaseControl {
    let titleFont: UIFont = .preferredFont(forTextStyle: .footnote)

    private(set) lazy var titleLabel = UILabel().then {
        $0.font = titleFont.withTraits(.traitBold)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.textColor = colorStyle.textColor
        $0.isHidden = true
    }

    private(set) lazy var contentContainerView = UIStackView.horizontal().then {
        $0.spacing = defaultSpacing
        $0.addArrangedSubviews(
            titleLabel,
            contentView
        )
    }

    private(set) lazy var containerView = UIStackView.vertical(
        .arrangedSubviews(contentContainerView),
        .spacing(defaultSpacing),
        .isLayoutMarginsRelativeArrangement(true),
        .directionalLayoutMargins(vertical: defaultSpacing)
    )

    private lazy var separator = SeparatorView(style: .soft)

    var isShowingSeparator: Bool {
        get {
            separator.isHidden == false
        }
        set {
            separator.isSafelyHidden = !newValue
        }
    }

    var axis: NSLayoutConstraint.Axis {
        get {
            contentContainerView.axis
        }
        set {
            contentContainerView.axis = newValue
        }
    }

    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
            titleLabel.isHidden = newValue.isNilOrEmpty
        }
    }

    init(title: String?, isEnabled: Bool = true, frame: CGRect = .zero) {
        super.init(frame: frame)

        self.title = title

        self.isEnabled = isEnabled
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTitleSectionStyle() {
        titleLabel.font = .preferredFont(forTextStyle: .callout)
        titleLabel.textColor = colorStyle.secondaryTextColor
        contentContainerView.directionalLayoutMargins.update(top: elementInspectorAppearance.horizontalMargins)
        contentContainerView.setCustomSpacing(elementInspectorAppearance.verticalMargins * 1.5, after: titleLabel)
    }

    override open func setup() {
        super.setup()

        tintColor = colorStyle.textColor

        installView(containerView, priority: .required)

        installSeparator()
    }

    private func installSeparator() {
        separator.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(separator)

        separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}
