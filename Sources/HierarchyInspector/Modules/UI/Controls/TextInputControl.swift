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
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.adjustsFontSizeToFitWidth = true
        $0.addTarget(self, action: #selector(editText), for: .allEditingEvents)
    }
        
    private(set) lazy var accessoryControl = ViewInspectorControlAccessoryControl().then {
        $0.contentView.addArrangedSubview(textField)
        
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    override var isEnabled: Bool {
        didSet {
            textField.isEnabled = isEnabled
            accessoryControl.isEnabled = isEnabled
        }
    }
    
    // MARK: - Init
    
    private(set) var value: String?
    
    private(set) var placeholder: String? {
        get {
            textField.placeholder
        }
        set {
            textField.placeholder = newValue?.localizedCapitalized
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
    
    @objc private func editText() {
        guard value != textField.text else {
            return
        }
        
        value = textField.text
        
        sendActions(for: .valueChanged)
    }
}
