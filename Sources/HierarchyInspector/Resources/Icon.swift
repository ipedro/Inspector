//
//  Icon.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

extension Icon {
    enum Glyph: String {
        case chevronDown
        case chevronUpDown
        case infoCircle
        case wifiExlusionMark
        case eyeSlashFill
        case listBulletIndent
        
        fileprivate func draw(color: UIColor, frame: CGRect, resizing: IconKit.ResizingBehavior) {
            switch self {
            case .chevronDown:
                IconKit.drawChevronDown(color: color, frame: frame, resizing: resizing)
                
            case .infoCircle:
                IconKit.drawInfoCircle(color: color, frame: frame, resizing: resizing)
            
            case .wifiExlusionMark:
                IconKit.drawWifiExlusionMark(color: color, frame: frame, resizing: resizing)
                
            case .eyeSlashFill:
                IconKit.drawEyeSlashFill(color: color, frame: frame, resizing: resizing)
                
            case .listBulletIndent:
                IconKit.drawListBulletIndent(color: color, frame: frame, resizing: resizing)
                
            case .chevronUpDown:
                IconKit.drawChevronUpDown(color: color, frame: frame, resizing: resizing)
            }
        }
    }
}

final class Icon: BaseView {
    let glpyh: Glyph
    
    let color: UIColor
    
    let size: CGSize
    
    private(set) lazy var widthConstraint = widthAnchor.constraint(equalToConstant: size.width).then {
        $0.priority = .defaultHigh
    }
    
    private(set) lazy var heightConstraint = heightAnchor.constraint(equalToConstant: size.height).then {
        $0.priority = .defaultHigh
    }
    
    init(_ glpyh: Glyph, color: UIColor, size: CGSize = CGSize(width: 16, height: 16)) {
        self.glpyh = glpyh
        self.color = color
        self.size = size
        
        super.init(frame: CGRect(origin: .zero, size: size))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var description: String {
        "\(className) '\(glpyh)'\nsize: \(size) \ncolor: \(color)"
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
        glpyh.draw(color: color, frame: bounds, resizing: .aspectFit)
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
