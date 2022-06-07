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

final class HierarchyInspectorSearchView: BaseView {
    private lazy var searchIcon = Icon(
        .search,
        color: colorStyle.textColor.withAlphaComponent(0.73),
        size: CGSize(19)
    )

    private(set) lazy var textField = DismissableTextField(
        .clearButtonMode(.always),
        .textStyle(.title2),
        .textColor(colorStyle.textColor),
        .attributedPlaceholder(
            NSAttributedString(
                Texts.searchViews,
                .foregroundColor(colorStyle.secondaryTextColor),
                .textStyle(.title2)
            )
        )
    )

    private(set) lazy var separatorView = SeparatorView(style: .medium, thickness: UIScreen.main.scale)

    override var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }

    override var isFirstResponder: Bool {
        textField.isFirstResponder
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder() // must call super at one point
        return textField.becomeFirstResponder()
    }

    override func setup() {
        super.setup()

        contentView.axis = .horizontal
        contentView.alignment = .center
        contentView.directionalLayoutMargins = elementInspectorAppearance.directionalInsets.with(trailing: elementInspectorAppearance.verticalMargins)
        contentView.spacing = elementInspectorAppearance.verticalMargins

        contentView.addArrangedSubview(searchIcon)
        contentView.addArrangedSubview(textField)

        installView(separatorView, .spacing(leading: .zero, bottom: -separatorView.thickness, trailing: .zero))
    }
}

// MARK: - APIs

extension HierarchyInspectorSearchView {
    var query: String? {
        textField.text
    }

    var hasText: Bool {
        textField.hasText
    }

    func insertText(_ text: String) {
        textField.insertText(text)
    }

    func deleteBackward() {
        textField.deleteBackward()
    }
}

extension HierarchyInspectorSearchView {
    final class DismissableTextField: UITextField {
        override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
            for press in presses {
                switch press.key?.keyCode {
                case .keyboardUpArrow,
                     .keyboardDownArrow,
                     .keyboardTab:
                    resignFirstResponder()
                default:
                    super.pressesBegan(presses, with: event)
                }
            }
        }
    }
}
