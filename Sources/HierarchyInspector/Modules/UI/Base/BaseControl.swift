//
//  BaseControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

class BaseControl: UIControl {
    
    private(set) lazy var titleLabel = UILabel(.footnote).then {
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
    }
    
    private(set) lazy var contentView = UIStackView(axis: .horizontal, spacing: Self.spacing)
    
    static var spacing: CGFloat = 10
    
    private lazy var contentContainerView = UIStackView(
        axis: .horizontal,
        arrangedSubviews: [
            titleLabel,
            contentView
        ],
        spacing: Self.spacing,
        margins: .margins(top: Self.spacing)
    )
    
    private lazy var containerView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            contentContainerView,
            separator
        ],
        spacing: Self.spacing
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
    }
    
}

extension BaseControl {
    final class AccessoryContainerView: BaseView {
        
        override func setup() {
            super.setup()
            
            contentView.axis = .horizontal
            contentView.spacing = 8
            contentView.directionalLayoutMargins = .margins(horizontal: 12, vertical: 9)
            
            layer.cornerRadius = 8
            
            #warning("TODO: move to theme")
            backgroundColor = {
                let defaultColor = UIColor(hex: "EEEEEF")
                
                if #available(iOS 13.0, *) {
                    return UIColor { trait -> UIColor in
                        switch trait.userInterfaceStyle {
                        case .dark:
                            return UIColor(hex: "313136")
                            
                        default:
                            return defaultColor
                        }
                    }
                }
                
                return defaultColor
            }()
        }
    }
}
