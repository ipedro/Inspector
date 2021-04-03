//
//  Icon.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class Icon: BaseView {
    let glpyh: Glyph
    
    var size: CGSize {
        didSet {
            widthConstraint.constant  = size.width
            heightConstraint.constant = size.height
        }
    }
    
    private lazy var widthConstraint = widthAnchor.constraint(equalToConstant: size.width).then {
        $0.priority = .defaultHigh
    }
    
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: size.height).then {
        $0.priority = .defaultHigh
    }
    
    init(_ glpyh: Glyph, color: UIColor, size: CGSize = CGSize(width: 16, height: 16)) {
        self.glpyh = glpyh
        self.size = size
        
        super.init(frame: CGRect(origin: .zero, size: size))
        
        self.tintColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var description: String {
        "\(className) '\(glpyh)'\nsize: \(size) \ncolor: \(String(describing: tintColor))"
    }
    
    override func setup() {
        super.setup()
        
        isOpaque = false
        
        isUserInteractionEnabled = false
        
        translatesAutoresizingMaskIntoConstraints = false
        
        widthConstraint.isActive = true
        
        heightConstraint.isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        glpyh.draw(color: tintColor, frame: bounds, resizing: .aspectFit)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setNeedsDisplay()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        setNeedsDisplay()
    }
}

extension Icon {
    
    static func chevronDownIcon() -> Icon {
        Icon(
            .chevronDown,
            color: ElementInspector.configuration.appearance.textColor.withAlphaComponent(0.7),
            size: CGSize(
                width: ElementInspector.configuration.appearance.verticalMargins,
                height: ElementInspector.configuration.appearance.verticalMargins
            )
        ).then {
            $0.alpha = 0.8
        }
    }
    
}
