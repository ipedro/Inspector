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

protocol ElementInspectorFormViewCodeDelegate: AnyObject {
    func elementInspectorFormView(_ view: ElementInspectorFormView, isPointerInUse: Bool)
}

protocol ElementInspectorFormView: BaseView {
    var delegate: ElementInspectorFormViewCodeDelegate? { get set }
    var keyboardHeight: CGFloat { get set }
    var scrollView: UIScrollView { get }
    var isPointerInUse: Bool { get }
}

final class ElementInspectorFormViewCode: BaseView, ElementInspectorFormView {
    weak var delegate: ElementInspectorFormViewCodeDelegate?
    
    private(set) lazy var scrollView = UIScrollView(
        .alwaysBounceVertical(true),
        .keyboardDismissMode(.onDrag),
        .indicatorStyle(.white)
    )
    
    #if swift(>=5.0)
    @available(iOS 13.0, *)
    private lazy var hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
    #endif
    
    private(set) var isPointerInUse = false {
        didSet {
            delegate?.elementInspectorFormView(self, isPointerInUse: isPointerInUse)
        }
    }
    
    var keyboardHeight: CGFloat = .zero {
        didSet {
            scrollView.contentInset = UIEdgeInsets(bottom: keyboardHeight)
        }
    }
    
    override func setup() {
        super.setup()
        
        scrollView.installView(contentView)
        
        installView(scrollView)
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(bottom: ElementInspector.appearance.verticalMargins)
    }
    
    #if swift(>=5.0)
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        guard let window = window else {
            if #available(iOS 13.0, *) {
                hoverGestureRecognizer.isEnabled = false
            }
            
            return
        }
        
        if #available(iOS 13.0, *) {
            window.addGestureRecognizer(hoverGestureRecognizer)
            hoverGestureRecognizer.isEnabled = true
        }
        
        if #available(iOS 14.0, *) {
            hoverGestureRecognizer.isEnabled = ProcessInfo().isiOSAppOnMac == false
        }
    }
    
    @available(iOS 13.0, *)
    @objc
    func hovering(_ recognizer: UIHoverGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            isPointerInUse = true
            
        case .ended, .cancelled:
            isPointerInUse = false
            
        default:
            break
        }
    }
    #endif
}
