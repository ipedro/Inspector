//
//  LoaderView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

final class LoaderView: InternalView {
    // MARK: - Components
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .whiteLarge).then {
        $0.hidesWhenStopped   = true
        
        $0.startAnimating()
    }
    
    private lazy var checkmarkLabel = UILabel().then {
        $0.adjustsFontSizeToFitWidth = true
        $0.font               = .systemFont(ofSize: 50, weight: .medium)
        $0.text               = "✓"
        $0.textColor          = .white
        $0.textAlignment      = .center
        $0.isSafelyHidden     = true
    }
    
    private lazy var colorScheme: ColorScheme = .colorScheme { _ in .systemBlue }
    
    private(set) lazy var highlightView = HighlightView(
        frame: bounds,
        name: elementName,
        colorScheme: colorScheme,
        reference: ViewHierarchyReference(view: self)
    )
    
    var currentOperation: HierarchyInspector.Manager.Operation?
    
    override var accessibilityIdentifier: String? {
        didSet {
            if let name = accessibilityIdentifier {
                highlightView.name = name
            }
        }
    }
    // MARK: - Init
    
    private init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    func setup() {
        isUserInteractionEnabled = false
        
        backgroundColor = HierarchyInspector.ColorScheme.default.color(for: activityIndicator)
        
        layer.cornerRadius = 12
        
        installView(checkmarkLabel, constraints: .centerXY)
        
        installView(activityIndicator, constraints: .allMargins(8))
        
        installView(highlightView)
        
        addInspectorViews()
        
        checkmarkLabel.widthAnchor.constraint(equalTo:  activityIndicator.widthAnchor).isActive  = true
        checkmarkLabel.heightAnchor.constraint(equalTo: activityIndicator.heightAnchor).isActive = true
    }
    
    func addInspectorViews() {
        subviews.forEach { element in
            element.layer.cornerRadius = layer.cornerRadius * 0.5
            
            let inspectorView = WireframeView(
                frame: element.bounds,
                reference: ViewHierarchyReference(view: element),
                color: .white
            )
            
            element.installView(inspectorView, position: .bottom)
        }
        
        installView(highlightView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        highlightView.labelWidthConstraint = nil
    }
    
    func done() {
        activityIndicator.stopAnimating()
        
        checkmarkLabel.isSafelyHidden = false
    }
    
    func prepareForReuse() {
        currentOperation = nil
        
        activityIndicator.startAnimating()
        
        checkmarkLabel.isSafelyHidden = true
        alpha = 1
    }
}

// MARK: - Loader Pool Management

extension LoaderView {
    
    static var sharedPool: [UIView: LoaderView] = [:]
    
    static func dequeueLoaderView(for operation: HierarchyInspector.Manager.Operation, in presenter: LoaderViewPresentable) -> LoaderView {
        let loaderView = sharedPool[presenter] ?? LoaderView()
        
        loaderView.layer.removeAllAnimations()
        
        loaderView.prepareForReuse()
        
        loaderView.currentOperation = operation
        
        loaderView.accessibilityIdentifier = operation.name
        
        sharedPool[presenter] = loaderView
        
        return loaderView
    }
    
}
