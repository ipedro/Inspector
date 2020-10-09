//
//  OptionSelector.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class OptionSelector<Option: CustomStringConvertible>: BaseControl {
    // MARK: - Properties
    
    private lazy var icon = Icon(.chevronDown, color: valueLabel.textColor)
    
    private lazy var valueLabel = UILabel(.footnote).then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private lazy var valueContainerView = AccessoryContainerView().then {
        $0.contentView.addArrangedSubview(valueLabel)
        $0.contentView.addArrangedSubview(icon)
    }
    
    // MARK: - Init
    
    let options: [Option]
    
    var selectedIndex: Int

    init(title: String?, options: [Option], selectedIndex: Int = 0) {
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
        valueLabel.text = options.first?.description.localizedCapitalized
    }
}
