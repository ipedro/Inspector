//
//  HighlightView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

protocol HighlightViewDelegate: AnyObject {
    func highlightView(_ highlightView: HighlightView, didTapWith reference: ViewHierarchyReference)
}

extension HighlightViewDelegate {
    
    func hideAllHighlightViews(_ hide: Bool, containedIn reference: ViewHierarchyReference) {
        guard let referenceView = reference.view else {
            return
        }
        
        for view in referenceView.allSubviews where view is LayerViewProtocol {
            view.isSafelyHidden = hide
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
    
    let colorScheme: ColorScheme
    
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
    
    private lazy var label = UILabel().then {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        
        $0.textColor                 = .white
        $0.font                      = .preferredFont(forTextStyle: .caption1)
        $0.textAlignment             = .center
        $0.numberOfLines             = 1
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor        = 0.6
        
        $0.layer.shadowOffset        = CGSize(width: 0, height: 1)
        $0.layer.shadowColor         = UIColor.black.cgColor
        $0.layer.shadowRadius        = 0.8
        $0.layer.shadowOpacity       = 0.4
    }
    
    private(set) lazy var labelContentView = LayerViewComponent().then {
        $0.installView(label, .margins(horizontal: 4, vertical: 2))
        
        $0.layer.cornerRadius  = 6
        $0.layer.masksToBounds = true
        $0.backgroundColor = color
    }
    
    private lazy var labelContainerView = LayerViewComponent().then {
        $0.installView(labelContentView, .autoResizingMask)
        
        $0.layer.shadowOffset       = CGSize(width: 0, height: 1)
        $0.layer.shadowColor        = UIColor.black.cgColor
        $0.layer.shadowRadius       = 2
        $0.layer.shadowOpacity      = 0.6
        $0.layer.shouldRasterize    = true
        $0.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
    
    @objc
    func tap() {
        delegate?.highlightView(self, didTapWith: viewReference)
    }
    
    // MARK: - Init
    
    init(
        frame: CGRect,
        name: String,
        colorScheme: ColorScheme,
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
    
    public override func didMoveToSuperview() {
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
        
        name = superview?.elementName ?? viewReference.elementName
        
        updateLabelWidth()
        
        guard let superview = superview else {
            return
        }
        
        color = colorScheme.color(for: superview)
    }
    
}

private extension HighlightView {
    
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
