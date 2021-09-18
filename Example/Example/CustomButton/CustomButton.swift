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
import Inspector

final class CustomButton: UIButton, NonInspectableView {
    var animateOnTouch = true
    
    var roundCorners: Bool = true {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerCurve = .continuous
        layer.cornerRadius = roundCorners ? frame.height / 2 : .zero
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard animateOnTouch else {
            return
        }
        
        scale(.in, for: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard animateOnTouch else {
            return
        }
        
        scale(.out, for: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        guard animateOnTouch else {
            return
        }
        
        scale(.out, for: event)
    }
    
    enum Animation {
        case `in`, out
    }
    
    func scale(_ type: Animation, for event: UIEvent?) {
        switch event?.type {
        case .presses, .touches:
            break
            
        default:
            return
        }
        
        UIView.animate(.quickly) {
            switch type {
            case .in:
                self.transform = CGAffineTransform(scaleX: 0.92, y: 0.9)
                
            case .out:
                self.transform = .identity
            }
        }
    }
}
