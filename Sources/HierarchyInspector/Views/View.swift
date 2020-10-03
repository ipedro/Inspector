//
//  View.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public class View: UIImageView, InspectorViewProtocol {
    // MARK: - Properties
    
    var color: UIColor {
        didSet {
            guard color != oldValue else {
                return
            }
            
            layer.borderColor = color.withAlphaComponent(0.5).cgColor
        }
    }
    
    let borderWidth: CGFloat
    
    // MARK: - Init
    
    init(frame: CGRect, color: UIColor, borderWidth: CGFloat) {
        self.color = color
        self.borderWidth = borderWidth
        
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        
        layer.borderWidth = borderWidth
        
        layer.borderColor = color.withAlphaComponent(0.5).cgColor
        
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    public override func didMoveToSuperview() { // swiftlint:disable:this delegate_method_naming
        super.didMoveToSuperview()
        
        guard let superview = superview else {
            return
        }
        
        if superview.isSystemView == false {
            layer.maskedCorners = superview.layer.maskedCorners
        }
        
        if #available(iOS 13.0, *) {
            layer.cornerCurve = superview.layer.cornerCurve
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let superview = superview else {
            return
        }
                    
        layer.cornerRadius  = superview.layer.cornerRadius
    }
}
