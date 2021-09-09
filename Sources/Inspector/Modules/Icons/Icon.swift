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

final class Icon: BaseView {
    let glpyh: Glyph
    
    var size: CGSize {
        didSet {
            widthConstraint.constant  = size.width
            heightConstraint.constant = size.height
        }
    }
    
    private lazy var widthConstraint = widthAnchor.constraint(equalToConstant: size.width)
    
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: size.height)
    
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
            color: ElementInspector.appearance.textColor.withAlphaComponent(0.7),
            size: CGSize(16)
        )
    }
    
}
