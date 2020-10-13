//
//  BaseFormControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

class BaseFormControl: BaseControl {

    private(set) lazy var titleLabel = UILabel(.footnote).then {
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
    }
    
    override var isEnabled: Bool {
        didSet {
            titleLabel.alpha = isEnabled ? 1 : 0.5
        }
    }
    
    private lazy var contentContainerView = UIStackView(
        axis: .horizontal,
        arrangedSubviews: [
            titleLabel,
            contentView
        ],
        spacing: spacing
    )
    
    private lazy var containerView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            contentContainerView
        ],
        spacing: spacing,
        margins: .margins(
            horizontal: .zero,
            vertical: spacing
        )
    )
    
    private lazy var separator = SeparatorView()
    
    var isShowingSeparator: Bool {
        get {
            separator.isHidden == false
        }
        set {
            separator.isSafelyHidden = !newValue
        }
    }
    
    var axis: NSLayoutConstraint.Axis {
        get {
            contentContainerView.axis
        }
        set {
            contentContainerView.axis = newValue
        }
    }
    
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue?.localizedCapitalized
        }
    }
    
    init(title: String?, isEnabled: Bool = true, frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.title = title
        
        self.isEnabled = isEnabled
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setup() {
        super.setup()
        
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        tintColor = .systemPurple
        
        installView(containerView)
        
        installSeparator()
    }
    
    private func installSeparator() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(separator)
    
        separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
}