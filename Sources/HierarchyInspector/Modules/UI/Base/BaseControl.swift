//
//  BaseControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

class BaseControl: UIControl {
    
    let verticalMargins = ElementInspector.appearance.verticalMargins / 2
    
    let spacing = ElementInspector.appearance.verticalMargins
    
    private(set) lazy var titleLabel = UILabel(.footnote).then {
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
    }
    
    private(set) lazy var contentView = UIStackView(
        axis: .horizontal,
        spacing: spacing
    )
    
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
        spacing: verticalMargins,
        margins: .margins(
            horizontal: .zero,
            vertical: verticalMargins
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
    
    init(title: String?, frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.title = title
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setup() {
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

extension BaseControl {
    final class AccessoryContainerView: BaseView {
        
        override func setup() {
            super.setup()
            
            contentView.axis = .horizontal
            
            contentView.spacing = ElementInspector.appearance.verticalMargins / 2
            
            contentView.directionalLayoutMargins = .margins(horizontal: 12, vertical: 9) // matches UIStepper
            
            layer.cornerRadius = ElementInspector.appearance.verticalMargins / 2
            
            #warning("TODO: move to theme")
            backgroundColor = {
                if #available(iOS 13.0, *) {
                    return UIColor.label.withAlphaComponent(0.085)
                }
                
                return UIColor.black.withAlphaComponent(0.085)
            }()
        }
    }
}
