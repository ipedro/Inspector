//
//  ColorSelector.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class ColorSelector: BaseControl {
    // MARK: - Properties
    
    var color: UIColor {
        didSet {
            didUpdateColor()
        }
    }
    
    private lazy var colorDisplayView = BaseView().then {
        $0.layer.cornerRadius = 5
        $0.backgroundColor = color
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.gray.cgColor
        
        let widthConstraint = $0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: 4 / 3).then {
            $0.priority = .defaultHigh
        }
        
        widthConstraint.isActive = true
    }
    
    private lazy var colorLabel = UILabel(.footnote, text: String(describing: color)).then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private lazy var colorLabelContainer = AccessoryContainerView().then {
        $0.contentView.addArrangedSubview(colorDisplayView)
        $0.contentView.addArrangedSubview(colorLabel)
    }
    
    // MARK: - Init

    init(title: String?, color: UIColor) {
        self.color = color

        super.init(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
                
        contentView.addArrangedSubview(colorLabelContainer)
        
        didUpdateColor()
    }
    
    private func didUpdateColor() {
        colorDisplayView.backgroundColor = color
        colorLabel.text = "#" + color.hexDescription().uppercased()
    }
}
