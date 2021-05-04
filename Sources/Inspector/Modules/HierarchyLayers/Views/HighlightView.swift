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

protocol HighlightViewDelegate: AnyObject {
    func highlightView(_ highlightView: HighlightView, didTapWith reference: ViewHierarchyReference)
}

extension HighlightViewDelegate {
    
    func toggleHighlightViews(visibility isVisible: Bool, inside reference: ViewHierarchyReference) {
        guard let referenceRootView = reference.rootView else {
            return
        }
        
        for view in referenceRootView.allSubviews where view is LayerViewProtocol {
            view.isSafelyHidden = isVisible == false
        }
    }
    
}

class HighlightView: LayerView {
    weak var delegate: HighlightViewDelegate?
    
    // MARK: - Properties
    
    var name: String {
        didSet {
            label.text = name
        }
    }
    
    let colorScheme: ViewHierarchyColorScheme
    
    override var color: UIColor {
        didSet {
            guard color != oldValue else {
                return
            }
            
            labelContentView.backgroundColor = color
        }
    }
    
    var labelWidthConstraint: NSLayoutConstraint? {
        didSet {
            guard let oldConstraint = oldValue else {
                return
            }
            
            oldConstraint.isActive = false
        }
    }
    
    var verticalAlignmentOffset: CGFloat {
        get {
            verticalAlignmentConstraint.constant
        }
        set {
            verticalAlignmentConstraint.constant = newValue
        }
    }
    
    private lazy var verticalAlignmentConstraint = labelContainerView.centerYAnchor.constraint(equalTo: centerYAnchor)
    
    // MARK: - Components
    
    private lazy var label = UILabel(
        .huggingPriority(.required, for: .horizontal),
        .textColor(.white),
        .textStyle(.caption1),
        .textAlignment(.center),
        .numberOfLines(1),
        .adjustsFontSizeToFitWidth(true),
        .minimumScaleFactor(0.6),
        .layerOptions(
            .shadowOffset(CGSize(width: 0, height: 1)),
            .shadowColor(.black),
            .shadowRadius(0.8),
            .shadowOpacity(0.4)
        )
    )
    
    private(set) lazy var labelContentView = LayerViewComponent(
        .backgroundColor(color),
        .cornerRadius(6),
        .masksToBounds(true)
    ).then {
        $0.installView(label, .margins(horizontal: 4, vertical: 2))
    }
    
    private lazy var labelContainerView = LayerViewComponent(
        .layerOptions(
            .shadowOffset(CGSize(width: 0, height: 1)),
            .shadowColor(UIColor.black.cgColor),
            .shadowRadius(2),
            .shadowOpacity(0.6),
            .shouldRasterize(true),
            .rasterizationScale(UIScreen.main.scale)
        )
    ).then {
        $0.installView(labelContentView, .autoResizingMask)
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
    
    // MARK: - Init
    
    init(
        frame: CGRect,
        name: String,
        colorScheme: ViewHierarchyColorScheme,
        reference: ViewHierarchyReference,
        borderWidth: CGFloat = 1
    ) {
        self.colorScheme = colorScheme
        
        self.name = name
        
        super.init(
            frame: frame,
            reference: reference,
            color: .systemGray,
            borderWidth: borderWidth
        )
        
        shouldPresentOnTop = true
        
        isUserInteractionEnabled = true
        
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        labelContainerView.frame.contains(point)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        updateColors(isTouching: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        updateColors()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        updateColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview else {
            labelContainerView.removeFromSuperview()
            label.text = nil
            return
        }
        
        setupViews(with: superview)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateElementName()
        
        updateLabelWidth()
        
        guard let superview = superview else {
            return
        }
        
        color = colorScheme.color(for: superview)
    }
    
    func updateElementName() {
        var superViewName: String {
            guard let superview = superview else {
                return viewReference.elementName
            }
            return superview.elementName
        }
        
        name = superViewName
    }
}

private extension HighlightView {
    
    @objc
    func tap() {
        delegate?.highlightView(self, didTapWith: viewReference)
    }
    
    func updateLabelWidth() {
        labelWidthConstraint?.constant = frame.width * 4 / 3
    }
    
    func setupViews(with hostView: UIView) {
        updateColors()
        
        installView(labelContainerView, .centerX)
        
        verticalAlignmentConstraint.isActive = true
        
        label.text = name
        
        labelWidthConstraint = label.widthAnchor.constraint(equalToConstant: frame.width).then {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        
        isSafelyHidden = false
    }
    
    func updateColors(isTouching: Bool = false) {
        switch isTouching {
        case true:
            layerBackgroundColor = color.withAlphaComponent(ElementInspector.appearance.disabledAlpha)
            layerBorderColor     = color.withAlphaComponent(1)
            
        case false:
            layerBackgroundColor = color.withAlphaComponent(ElementInspector.appearance.disabledAlpha / 10)
            layerBorderColor     = color.withAlphaComponent(ElementInspector.appearance.disabledAlpha * 2)
        }
    }
}
