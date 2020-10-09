//
//  ColorPicker.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

protocol ColorPickerDelegate: AnyObject {
    func colorPickerDidTap(_ colorPicker: ColorPicker, sourceRect: CGRect)
}

final class ColorPicker: BaseControl {
    // MARK: - Properties
    
    weak var delegate: ColorPickerDelegate?
    
    var selectedColor: UIColor {
        didSet {
            didUpdateColor()
            
            sendActions(for: .valueChanged)
        }
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
    
    private lazy var colorDisplayView = BaseView().then {
        $0.layer.cornerRadius = 5
        $0.backgroundColor = selectedColor
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.gray.cgColor
        
        let widthConstraint = $0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: 4 / 3).then {
            $0.priority = .defaultHigh
        }
        
        widthConstraint.isActive = true
    }
    
    private lazy var colorLabel = UILabel(.footnote, String(describing: selectedColor)).then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private lazy var colorLabelContainer = AccessoryContainerView().then {
        $0.contentView.addArrangedSubview(colorDisplayView)
        $0.contentView.addArrangedSubview(colorLabel)
        
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
        
        contentView.addArrangedSubview(colorLabelContainer)
        
        didUpdateColor()
    }
    
    private func didUpdateColor() {
        colorDisplayView.backgroundColor = selectedColor
        colorLabel.text = "#" + selectedColor.hexDescription().uppercased()
    }
    
    @objc private func tap() {
        let rect = colorLabel.convert(bounds, to: nil)
        
        delegate?.colorPickerDidTap(self, sourceRect: rect)
    }
}
