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

final class ColorPicker: BaseControl {
    // MARK: - Properties
    
    weak var delegate: ColorPickerDelegate?
    
    var selectedColor: UIColor? {
        didSet {
            didUpdateColor()
            
            sendActions(for: .valueChanged)
        }
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
    
    private lazy var selectedColorView = BaseView().then {
        $0.layer.cornerRadius = 5
        $0.backgroundColor = selectedColor
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.gray.cgColor
        
        let widthConstraint = $0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: 4 / 3).then {
            $0.priority = .defaultHigh
        }
        
        widthConstraint.isActive = true
    }
    
    private lazy var valueLabel = UILabel(.footnote, String(describing: selectedColor)).then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.6
    }
    
    private(set) lazy var valueContainerView = AccessoryContainerView().then {
        $0.contentView.addArrangedSubview(selectedColorView)
        $0.contentView.addArrangedSubview(valueLabel)
        
        $0.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Init
    
    init(title: String?, color: UIColor?) {
        self.selectedColor = color ?? .clear
        
        super.init(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(valueContainerView)
        
        #if swift(>=5.3)
        isEnabled = true
        #else
        isEnabled = false
        valueContainerView.backgroundColor = nil
        
        var margins = valueContainerView.contentView.directionalLayoutMargins
        margins.leading = 0
        margins.trailing = 0
        
        valueContainerView.contentView.directionalLayoutMargins = margins
        #endif
        
        didUpdateColor()
    }
    
    private func didUpdateColor() {
        selectedColorView.backgroundColor = selectedColor
        
        switch selectedColor {
        case .none:
            valueLabel.text = "–"
            
        case UIColor.clear:
            valueLabel.text = "Clear Color"
        
        case let color?:
            var colorHex = "#" + color.hexDescription().uppercased()
            
            defer {
                valueLabel.text = colorHex
            }
            
            guard color.rgba.alpha < 1 else {
                return
            }
            
            colorHex += " (\(Int(color.rgba.alpha * 100))%)"
        }
    }
    
    @objc private func tap() {
        delegate?.colorPickerDidTap(self)
    }
}