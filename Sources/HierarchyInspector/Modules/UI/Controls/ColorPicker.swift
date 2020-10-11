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
    
    private lazy var selectedColorView = UIControl().then {
        $0.layer.cornerRadius = 5
        $0.backgroundColor = selectedColor
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.gray.cgColor
        
        $0.heightAnchor.constraint(equalToConstant: 16).isActive = true
        $0.widthAnchor.constraint(equalToConstant: 32).isActive = true
        
        $0.addTarget(self, action: #selector(tap), for: .touchDown)
    }
    
    private lazy var valueLabel = UITextView(.footnote).then {
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.textContainer.widthTracksTextView = true
    }
    
    private(set) lazy var valueContainerView = AccessoryContainerView().then {
        $0.contentView.alignment = .center
        
        $0.contentView.addArrangedSubview(valueLabel)
        
        $0.contentView.addArrangedSubview(selectedColorView)
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
        
        didUpdateColor()
        
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
