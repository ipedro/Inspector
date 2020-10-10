//
//  OptionSelector.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

protocol OptionSelectorDelegate: AnyObject {
    func optionSelectorDidTap(_ optionSelector: OptionSelector)
}

final class OptionSelector: BaseControl {
    // MARK: - Properties
    
    weak var delegate: OptionSelectorDelegate?
    
    private lazy var icon = Icon(.chevronDown, color: valueLabel.textColor)
    
    private lazy var valueLabel = UILabel(.footnote).then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.6
    }
    
    private(set) lazy var valueContainerView = AccessoryContainerView().then {
        $0.contentView.addArrangedSubview(valueLabel)
        $0.contentView.addArrangedSubview(icon)
        
        $0.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
    
    // MARK: - Init
    
    let options: [CustomStringConvertible]
    
    var selectedIndex: Int? {
        didSet {
            updateViews()
        }
    }

    init(title: String?, options: [CustomStringConvertible], selectedIndex: Int? = nil) {
        self.options = options
        
        self.selectedIndex = selectedIndex

        super.init(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(valueContainerView)
        
        tintColor = valueLabel.textColor
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let selectedIndex = selectedIndex else {
            valueLabel.text = "–"
            return
        }
        
        valueLabel.text = options[selectedIndex].description.localizedCapitalized
    }
    
    @objc private func tap() {
        delegate?.optionSelectorDidTap(self)
    }
}
