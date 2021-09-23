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

final class TextViewControl: BaseFormControl {
    // MARK: - Properties

    private lazy var textView = UITextView(
        .backgroundColor(nil),
        .isScrollEnabled(false),
        .textColor(colorStyle.textColor),
        .textStyle(.footnote),
        .delegate(self)
    ).then {
        let padding = $0.textContainer.lineFragmentPadding

        $0.textContainerInset = UIEdgeInsets(
            top: padding,
            left: padding * -1,
            bottom: padding,
            right: padding * -1
        )
    }

    private lazy var placeholderLabel = UILabel(
        .font(textView.font!),
        .numberOfLines(.zero),
        .textColor(colorStyle.secondaryTextColor)
    )

    private(set) lazy var accessoryControl = AccessoryControl().then {
        $0.animateOnTouch = false
        $0.contentView.addArrangedSubview(textView)
    }

    override var isEnabled: Bool {
        didSet {
            textView.isEditable = isEnabled
        }
    }

    // MARK: - Init

    var value: String? {
        didSet {
            guard value != textView.text else {
                return
            }

            textView.text = value
        }
    }

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    init(title: String?, value: String?, placeholder: String?) {
        self.value = value

        super.init(title: title)

        self.placeholder = placeholder
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        axis = .vertical

        contentView.addArrangedSubview(accessoryControl)

        textView.installView(
            placeholderLabel,
            .spacing(
                top: textView.textContainerInset.top,
                leading: .zero,
                bottom: textView.textContainerInset.bottom,
                trailing: .zero
            )
        )

        updateViews()
    }

    func updateViews() {
        placeholderLabel.text = placeholder
        textView.text = value
    }

    override var canBecomeFirstResponder: Bool {
        textView.canBecomeFirstResponder
    }

    override var canBecomeFocused: Bool {
        textView.canBecomeFocused
    }

    override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        placeholderLabel.preferredMaxLayoutWidth = placeholderLabel.frame.width
    }
}

// MARK: - Private Actions

private extension TextViewControl {
    @objc
    func editText() {
        guard value != textView.text else {
            return
        }

        value = textView.text
        placeholderLabel.isHidden = !value.isNilOrEmpty

        sendActions(for: .valueChanged)
    }
}

// MARK: - UITextViewDelegate

extension TextViewControl: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        editText()
    }
}
