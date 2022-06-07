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
        .tintColor(colorStyle.tintColor),
        .delegate(self)
    ).then {
        $0.isSelectable = true

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
        $0.addInteraction(UIContextMenuInteraction(delegate: self))
    }

    override var isEnabled: Bool {
        get { true }
        set {
            textView.isEditable = newValue
        }
    }

    // MARK: - Init

    var value: String? {
        didSet {
            guard value != textView.text else {
                return
            }

            updateViews()
        }
    }

    var placeholder: String? {
        didSet {
            updateViews()
        }
    }

    init(title: String?, value: String?, placeholder: String?) {
        self.value = value
        self.placeholder = placeholder

        super.init(title: title)
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

    private let aspectRatio: CGFloat = 3 / 5

    private lazy var textViewHeightConstraint = textView.heightAnchor.constraint(equalTo: textView.widthAnchor, multiplier: aspectRatio)

    private var isScrollEnabled: Bool = false {
        didSet {
            textViewHeightConstraint.isActive = isScrollEnabled
            textView.isScrollEnabled = isScrollEnabled
        }
    }

    var hasLongText: Bool {
        let trimmedString = String((value ?? "").filter { " \n\t\r".contains($0) == false })

        return trimmedString.count > 320
    }

    func updateViews() {
        placeholderLabel.text = placeholder
        placeholderLabel.isHidden = placeholder.isNilOrEmpty || !value.isNilOrEmpty
        textView.text = value

        isScrollEnabled = hasLongText
        accessoryControl.directionalLayoutMargins = !hasLongText ? .zero : .init(horizontal: .zero, vertical: elementInspectorAppearance.verticalMargins)
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

    override func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                         configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration?
    {
        let localPoint = convert(location, to: accessoryControl)

        guard accessoryControl.point(inside: localPoint, with: nil) else { return nil }

        var actions = [UIMenuElement]()

        if let range = textView.selectedTextRange {
            let copySelectionAction = UIAction(
                title: "Copy selection",
                image: .copySymbol,
                identifier: nil,
                discoverabilityTitle: "Copy selection",
                handler: { [weak self] _ in
                    guard let self = self else { return }
                    UIPasteboard.general.string = self.textView.text(in: range)
                }
            )
            actions.append(copySelectionAction)
        }

        let copyAllAction = UIAction(
            title: "Copy all content",
            image: .copySymbol,
            identifier: nil,
            discoverabilityTitle: "Copy all content",
            handler: { [weak self] _ in
                guard let self = self else { return }
                UIPasteboard.general.string = self.textView.text
            }
        )

        actions.append(copyAllAction)

        return .init(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            UIMenu(
                title: "",
                image: nil,
                identifier: nil,
                children: actions
            )
        }
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
