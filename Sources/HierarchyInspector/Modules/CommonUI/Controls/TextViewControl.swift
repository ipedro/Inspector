//
//  TextViewControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.12.20.
//

import UIKit

final class TextViewControl: BaseFormControl {
    // MARK: - Properties
    
    private lazy var textView = UITextView().then {
        let padding = $0.textContainer.lineFragmentPadding
        
        $0.textContainerInset = .insets(
            top: padding,
            left: padding * -1,
            bottom: padding,
            right: padding * -1
        )
        $0.backgroundColor = nil
        $0.isScrollEnabled = false
        $0.textColor = ElementInspector.appearance.textColor
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.delegate = self
    }
    
    private lazy var placeholderLabel = UILabel().then {
        $0.font = textView.font
        $0.numberOfLines = 0
        $0.textColor = ElementInspector.appearance.secondaryTextColor
    }
    
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        
        axis = .vertical
        
        contentView.addArrangedSubview(accessoryControl)
        
        textView.installView(
            placeholderLabel,
            .margins(
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
