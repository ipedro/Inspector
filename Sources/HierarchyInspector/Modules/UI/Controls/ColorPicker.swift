//
//  ColorPicker.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

protocol ColorPickerDelegate: AnyObject {
    func colorPickerDidTap(_ colorPicker: ColorPicker)
}

final class ColorPicker: BaseFormControl {
    // MARK: - Properties
    
    weak var delegate: ColorPickerDelegate?
    
    var selectedColor: UIColor? {
        didSet {
            didUpdateColor()
        }
    }
    
    func updateSelectedColor(_ color: UIColor?) {
        selectedColor = color
        
        sendActions(for: .valueChanged)
    }
    
    override var isEnabled: Bool {
        didSet {
            tapGestureRecognizer.isEnabled = isEnabled
            accessoryControl.isEnabled = isEnabled
        }
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapColor))
    
    private lazy var colorDisplayControl = ColorDisplayControl().then {
        $0.color = selectedColor
        
        $0.heightAnchor.constraint(equalToConstant: 16).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: 2).isActive = true
    }
    
    private lazy var colorDisplayLabel = UILabel(.footnote).then {
        $0.font = $0.font?.withTraits(traits: .traitMonoSpace)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private(set) lazy var accessoryControl = AccessoryControl().then {
        $0.addGestureRecognizer(tapGestureRecognizer)
        $0.contentView.addArrangedSubview(colorDisplayLabel)
        $0.contentView.addArrangedSubview(colorDisplayControl)
    }
    
    // MARK: - Init
    
    init(title: String?, color: UIColor?) {
        self.selectedColor = color
        
        super.init(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(accessoryControl)
        
        didUpdateColor()
        
        #if swift(>=5.3)
        colorDisplayControl.isEnabled = true
        #else
        accessoryControl.isUserInteractionEnabled = false
        colorDisplayLabel.textColor = .systemPurple
        accessoryControl.backgroundColor = nil
        
        var margins = accessoryControl.contentView.directionalLayoutMargins
        margins.leading = 0
        margins.trailing = 0
        
        accessoryControl.contentView.directionalLayoutMargins = margins
        #endif
    }
    
    private func didUpdateColor() {
        colorDisplayControl.color = selectedColor
        
        colorDisplayLabel.text = selectedColor?.hexDescription ?? "No color"
    }
    
    @objc private func tapColor() {
        delegate?.colorPickerDidTap(self)
    }
}

extension ColorPicker {
    
}
