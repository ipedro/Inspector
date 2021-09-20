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

final class TextFieldControl: BaseFormControl {
    private let defaultFont: UIFont = .preferredFont(forTextStyle: .footnote)

    // MARK: - Properties

    private lazy var textField = UITextField().then {
        $0.textColor = colorStyle.textColor
        $0.adjustsFontSizeToFitWidth = true
        $0.font = defaultFont
        $0.borderStyle = .none
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        $0.delegate = self
        $0.addTarget(self, action: #selector(editText), for: .editingChanged)
    }

    private(set) lazy var accessoryControl = AccessoryControl().then {
        $0.contentView.addArrangedSubview(textField)
    }

    override var isEnabled: Bool {
        didSet {
            textField.isEnabled = isEnabled
            accessoryControl.isEnabled = isEnabled
        }
    }

    // MARK: - Init

    var value: String? {
        get {
            textField.text
        }
        set {
            textField.text = newValue
        }
    }

    var placeholder: String? {
        get {
            textField.placeholder
        }
        set {
            guard let placeholder = newValue else {
                textField.placeholder = nil
                return
            }
            textField.attributedPlaceholder = NSAttributedString(
                placeholder,
                .font(textField.font ?? defaultFont),
                .foregroundColor(colorStyle.tertiaryTextColor)
            )
        }
    }

    init(title: String?, value: String?, placeholder: String?) {
        super.init(title: title)

        self.value = value
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
    }

    override var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }

    override var canBecomeFocused: Bool {
        textField.canBecomeFocused
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
}

private extension TextFieldControl {
    @objc
    func editText() {
        sendActions(for: .valueChanged)
    }
}

extension TextFieldControl: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
}
