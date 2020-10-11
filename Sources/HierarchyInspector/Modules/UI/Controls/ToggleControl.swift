//
//  ToggleControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class ToggleControl: BaseControl {
    // MARK: - Properties

    var isOn: Bool {
        get {
            switchControl.isOn
        }
        set {
            switchControl.setOn(newValue, animated: false)
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
        
        #if swift(>=5.3)
        if #available(iOS 14.0, *) {
            switchControl.preferredStyle = .checkbox
            switchControl.thumbTintColor = .tertiaryLabel
        }
        #elseif swift(>=5.0)
        if #available(iOS 13.0, *) {
            switchControl.thumbTintColor = .tertiaryLabel
        }
        #endif

        contentView.addArrangedSubview(switchControl)
        
        updateViews()
    }

    @objc func toggleOn() {
        updateViews()
        
        sendActions(for: .valueChanged)
    }
    
    func updateViews() {
        titleLabel.alpha = isOn ? 1 : 0.75
    }
}
