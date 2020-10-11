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

final class ColorPicker: ViewInspectorControl {
    // MARK: - Properties
    
    weak var delegate: ColorPickerDelegate?
    
    var selectedColor: UIColor? {
        didSet {
            didUpdateColor()
            
            sendActions(for: .valueChanged)
        }
    }
    
    private lazy var selectedColorView = ColorDisplayControl().then {
        $0.color = selectedColor
        $0.addTarget(self, action: #selector(tapColor), for: .touchUpInside)
        
        $0.heightAnchor.constraint(equalToConstant: 16).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: 2).isActive = true
    }
    
    private lazy var valueTextView = UITextView(.footnote).then {
        $0.font = $0.font?.withTraits(traits: .traitMonoSpace)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.textContainer.widthTracksTextView = true
    }
    
    private(set) lazy var valueContainerView = ViewInspectorControlAccessoryControl().then {
        $0.contentView.alignment = .center
        
        $0.contentView.addArrangedSubview(valueTextView)
        
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
        selectedColorView.isEnabled = true
        #else
        selectedColorView.isUserInteractionEnabled = false
        valueTextView.textColor = .systemPurple
        valueContainerView.backgroundColor = nil
        
        var margins = valueContainerView.contentView.directionalLayoutMargins
        margins.leading = 0
        margins.trailing = 0
        
        valueContainerView.contentView.directionalLayoutMargins = margins
        #endif
    }
    
    private func didUpdateColor() {
        selectedColorView.color = selectedColor
        
        valueTextView.text = selectedColor?.hexDescription ?? "–"
    }
    
    @objc private func dismissSelection() {
        valueTextView.selectedTextRange = nil
    }
    
    @objc private func tapColor() {
        delegate?.colorPickerDidTap(self)
    }
}

extension ColorPicker {
    
}
