//
//  TextInputControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit


final class TextInputControl: BaseFormControl {
    // MARK: - Properties
    
    private lazy var textField = UITextField().then {
        $0.borderStyle = .none
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.textAlignment = .right
        $0.adjustsFontSizeToFitWidth = true
        $0.addTarget(self, action: #selector(editText), for: .allEditingEvents)
        $0.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
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
        didSet {
            guard value != textField.text else {
                return
            }
            
            textField.text = value
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
        self.value = value

        super.init(title: title)
        
        self.placeholder = placeholder
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(accessoryControl)
        
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

private extension TextInputControl {
    
    @objc
    func editText() {
        guard value != textField.text else {
            return
        }
        
        value = textField.text
        
        sendActions(for: .valueChanged)
    }
}
