//
//  LayerView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

class LayerView: UIImageView, InternalViewProtocol {
    open var shouldPresentOnTop = false
    
    // MARK: - Properties
    
    var color: UIColor {
        didSet {
            guard color != oldValue else {
                return
            }
            
            layerBorderColor = color.withAlphaComponent(0.5)
        }
    }
    
    var layerBorderWidth: CGFloat {
        get {
            borderedView.layer.borderWidth
        }
        set {
            borderedView.layer.borderWidth = newValue
        }
    }
    
    var layerBackgroundColor: UIColor? {
        get {
            borderedView.backgroundColor
        }
        set {
            borderedView.backgroundColor = newValue
        }
    }
    
    var layerBorderColor: UIColor? {
        get {
            guard let borderColor = borderedView.layer.borderColor else {
                return nil
            }
            
            return UIColor(cgColor: borderColor)
        }
        set {
            borderedView.layer.borderColor = newValue?.cgColor
        }
    }
    
    private lazy var borderedView = InternalView(frame: bounds)
    
    let viewReference: ViewHierarchyReference
    
    // MARK: - Init
    
    init(frame: CGRect, reference: ViewHierarchyReference, color: UIColor, borderWidth: CGFloat) {
        self.viewReference = reference
        self.color = color
        
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        
        borderedView.layer.borderWidth = borderWidth
        
        borderedView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
        
        installView(borderedView)
        
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
            borderedView.layer.maskedCorners = superview.layer.maskedCorners
        }
        
        if #available(iOS 13.0, *) {
            borderedView.layer.cornerCurve = superview.layer.cornerCurve
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let superview = superview else {
            return
        }
        
        borderedView.layer.maskedCorners = superview.layer.maskedCorners
        
        borderedView.layer.cornerRadius = superview.layer.cornerRadius
    }
}
