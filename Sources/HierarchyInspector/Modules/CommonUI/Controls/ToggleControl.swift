//
//  ToggleControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class ToggleControl: BaseFormControl {
    // MARK: - Properties

    var isOn: Bool {
        get {
            switchControl.isOn
        }
        set {
            setOn(newValue, animated: false)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            switchControl.isEnabled = isEnabled
            
            guard isEnabled else {
                return
            }
            
            updateViews()
        }
    }
    
    
    private lazy var switchControl = UISwitch().then {
        $0.addTarget(self, action: #selector(toggleOn), for: .valueChanged)
    }

    // MARK: - Init

    init(title: String?, isOn: Bool) {
        super.init(title: title)
        
        self.isOn = isOn
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        switchControl.onTintColor = .systemPurple
        
        switchControl.thumbTintColor = ElementInspector.appearance.quaternaryTextColor
        
        contentView.addArrangedSubview(switchControl)
        
        updateViews()
    }
    
    func setOn(_ on: Bool, animated: Bool) {
        switchControl.setOn(on, animated: animated)
        
        updateViews()
    }

    @objc
    func toggleOn() {
        updateViews()
        
        sendActions(for: .valueChanged)
    }
    
    func updateViews() {
        titleLabel.alpha = isOn ? 1 : 0.75
    }
}