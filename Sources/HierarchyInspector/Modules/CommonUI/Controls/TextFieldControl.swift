//
//  TextFieldControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class TextFieldControl: BaseFormControl {
    // MARK: - Properties
    
    private lazy var textField = UITextField().then {
        $0.addTarget(self, action: #selector(editText), for: .editingChanged)
        $0.textColor = ElementInspector.appearance.textColor
        $0.adjustsFontSizeToFitWidth = true
        $0.borderStyle = .none
        $0.font = .preferredFont(forTextStyle: .footnote)
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
            textField.placeholder = newValue
        }
    }

    init(title: String?, value: String?, placeholder: String?) {
        super.init(title: title)

        textField.text = value
        textField.placeholder = placeholder
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        
        axis = .vertical
        
        contentView.addArrangedSubview(accessoryControl)
        
        accessoryControl.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor).isActive = true
        
        updateViews()
    }
    
    func updateViews() {
        textField.placeholder = placeholder
        textField.text = value
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
