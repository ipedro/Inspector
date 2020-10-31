//
//  OptionListControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

protocol OptionListControlDelegate: AnyObject {
    func optionListControlDidTap(_ optionListControl: OptionListControl)
}

final class OptionListControl: BaseFormControl {
    // MARK: - Properties
    
    weak var delegate: OptionListControlDelegate?
    
    override var isEnabled: Bool {
        didSet {
            tapGestureRecognizer.isEnabled = isEnabled
            icon.isHidden = isEnabled == false
            accessoryControl.isEnabled = isEnabled
        }
    }
    
    private lazy var icon = Icon(
        .chevronUpDown,
        color: ElementInspector.configuration.appearance.secondaryTextColor,
        size: CGSize(width: 14, height: 14)
    )
    
    private lazy var valueLabel = UILabel(.footnote, textColor: ElementInspector.configuration.appearance.textColor).then {
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.6
    }
    
    private(set) lazy var accessoryControl = AccessoryControl().then {
        $0.contentView.addArrangedSubview(valueLabel)
        $0.contentView.addArrangedSubview(icon)
        $0.contentView.alignment = .center
        $0.contentView.spacing = ElementInspector.configuration.appearance.verticalMargins
        $0.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
    
    // MARK: - Init
    
    let options: [CustomStringConvertible]
    
    let emptyTitle: String
    
    var selectedIndex: Int? {
        didSet {
            updateViews()
        }
    }
    
    init(
        title: String?,
        options: [CustomStringConvertible],
        emptyTitle: String,
        selectedIndex: Int? = nil
    ) {
        self.options = options
        
        self.selectedIndex = selectedIndex
        
        self.emptyTitle = emptyTitle

        super.init(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(accessoryControl)
        
        accessoryControl.widthAnchor.constraint(greaterThanOrEqualTo: contentContainerView.widthAnchor, multiplier: 1 / 2).isActive = true
        
        tintColor = valueLabel.textColor
        
        updateViews()
    }
    
    func updateSelectedIndex(_ selectedIndex: Int?) {
        self.selectedIndex = selectedIndex
        
        sendActions(for: .valueChanged)
    }
    
    private func updateViews() {
        
        guard let selectedIndex = selectedIndex else {
            valueLabel.text = emptyTitle
            return
        }
        
        valueLabel.text = options[selectedIndex].description
    }
    
    @objc private func tap() {
        delegate?.optionListControlDidTap(self)
    }
}
