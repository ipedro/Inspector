//
//  HighlightView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

class HighlightView: LayerView {
    
    override var shouldPresentOnTop: Bool {
        true
    }
    
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
    
    private var labelWidthConstraint: NSLayoutConstraint? {
        didSet {
            guard let oldConstraint = oldValue else {
                return
            }
            
            oldConstraint.isActive = false
        }
    }
    
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
    
    private lazy var labelContentView = InternalView().then {
        $0.installView(label, constraints: .margins(horizontal: 4, vertical: 2))
        
        $0.layer.cornerRadius  = 6
        $0.layer.masksToBounds = true
        $0.backgroundColor = color
    }
    
    private lazy var labelContainerView = InternalView().then {
        $0.installView(labelContentView)
        
        $0.layer.shadowOffset       = CGSize(width: 0, height: 1)
        $0.layer.shadowColor        = UIColor.black.cgColor
        $0.layer.shadowRadius       = 2
        $0.layer.shadowOpacity      = 0.6
        $0.layer.shouldRasterize    = true
        $0.layer.rasterizationScale = UIScreen.main.scale
    }
    
    // MARK: - Init
    
    init(frame: CGRect, name: String, colorScheme: ColorScheme, reference: ViewHierarchyReference, borderWidth: CGFloat = 1) {
        self.name = name
        self.colorScheme = colorScheme
        
        super.init(frame: frame, reference: reference, color: .systemGray, borderWidth: borderWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard
            newSuperview == nil,
            let superview = superview
        else {
            return
        }
        
        for highlightView in superview.find(highlightViewsNamed: name) where highlightView !== self {
            highlightView.setupViews(with: superview)
            
            return
        }
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview else {
            labelContainerView.removeFromSuperview()
            label.text = nil
            return
        }
        
        if superview.find(highlightViewsNamed: name).count == 1 {
            setupViews(with: superview)
        }
        else {
            isSafelyHidden = true
            labelWidthConstraint = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
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
        backgroundColor = color.withAlphaComponent(0.03)
        
        layer.borderColor = color.withAlphaComponent(0.7).cgColor
        
        installView(labelContainerView, constraints: .centerXY)
        
        label.text = name
        
        labelWidthConstraint = label.widthAnchor.constraint(equalToConstant: frame.width).then {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        
        isSafelyHidden = false
    }
    
}
