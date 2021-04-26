//  Copyright (c) 2021 Pedro Almeida
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

class LayerView: UIImageView, LayerViewProtocol {
    var shouldPresentOnTop = false
    
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
    
    private lazy var borderedView = LayerViewComponent(frame: bounds)
    
    let viewReference: ViewHierarchyReference
    
    // MARK: - Init
    
    init(frame: CGRect, reference: ViewHierarchyReference, color: UIColor, borderWidth: CGFloat) {
        self.viewReference = reference
        self.color = color
        
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        
        borderedView.layer.borderWidth = borderWidth
        
        borderedView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
        
        installView(borderedView, .autoResizingMask)
        
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview else {
            return
        }
        
        if superview.isSystemView == false {
            borderedView.layer.maskedCorners = superview.layer.maskedCorners
        }
        
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            borderedView.layer.cornerCurve = superview.layer.cornerCurve
        }
        #endif
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let superview = superview else {
            return
        }
        
        borderedView.layer.maskedCorners = superview.layer.maskedCorners
        
        borderedView.layer.cornerRadius = superview.layer.cornerRadius
    }
}
