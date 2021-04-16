//
//  BaseFormControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

class BaseFormControl: BaseControl {

    private(set) lazy var titleLabel = UILabel(
        .textStyle(.footnote),
        .huggingPriority(.fittingSizeLevel, for: .horizontal),
        .textColor(ElementInspector.appearance.textColor)
    )
    
    override var isEnabled: Bool {
        didSet {
            titleLabel.alpha = isEnabled ? 1 : 0.5
        }
    }
    
    private(set) lazy var contentContainerView = UIStackView.horizontal(
        .arrangedSubviews(
            titleLabel,
            contentView
        ),
        .spacing(defaultSpacing)
    )
    
    private lazy var containerView = UIStackView.vertical(
        .arrangedSubviews(contentContainerView),
        .spacing(defaultSpacing),
        .directionalLayoutMargins(vertical: defaultSpacing)
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
            titleLabel.text = newValue
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
