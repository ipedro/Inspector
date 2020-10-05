//
//  LayerView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

class LayerView: UIImageView, HierarchyInspectorViewProtocol {
    open var shouldPresentOnTop: Bool { false }
    
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
    
    let viewReference: ViewHierarchyReference
    
    // MARK: - Init
    
    init(frame: CGRect, reference: ViewHierarchyReference, color: UIColor, borderWidth: CGFloat) {
        self.viewReference = reference
        self.color = color
        self.borderWidth = borderWidth
        
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        
        layer.borderWidth = borderWidth
        
        layer.borderColor = color.withAlphaComponent(0.5).cgColor
        
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    public override func didMoveToSuperview() {
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
