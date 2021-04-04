//
//  ColorPreviewControl.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

protocol ColorPreviewControlDelegate: AnyObject {
    func colorPreviewControlDidTap(_ colorPreviewControl: ColorPreviewControl)
}

final class ColorPreviewControl: BaseFormControl {
    // MARK: - Properties
    
    weak var delegate: ColorPreviewControlDelegate?
    
    var selectedColor: UIColor? {
        didSet {
            updateViews()
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
        
        $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: 2).isActive = true
    }
    
    private lazy var colorDisplayLabel = UILabel(.footnote, textColor: ElementInspector.appearance.textColor).then {
//        $0.font = $0.font?.withTraits(traits: .traitMonoSpace)
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
        
        updateViews()
        
    }
    
    private func updateViews() {
        colorDisplayControl.color = selectedColor
        
        colorDisplayLabel.text = selectedColor?.hexDescription ?? "No color"
    }
    
    @objc private func tapColor() {
        delegate?.colorPreviewControlDidTap(self)
    }
}

extension ColorPreviewControl {
    
    final class ColorDisplayControl: BaseControl {
        
        var color: UIColor? {
            didSet {
                colorBackgroundView.backgroundColor = color
            }
        }
        
        private lazy var colorBackgroundView = UIView().then {
            $0.backgroundColor = nil
            $0.isUserInteractionEnabled = false
        }
        
        override func setup() {
            super.setup()
            
            backgroundColor = ElementInspector.appearance.tertiaryTextColor
            
            layer.cornerRadius = 5
            
            layer.masksToBounds = true
            
            installView(colorBackgroundView)
        }
        
        override func draw(_ rect: CGRect) {
            IconKit.drawColorGrid(frame: bounds, resizing: .aspectFill)
        }
    }

}
