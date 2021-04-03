//
//  LoaderView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

final class LoaderView: LayerViewComponent {
    // MARK: - Components
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .whiteLarge).then {
        $0.hidesWhenStopped = true
        $0.startAnimating()
    }
    
    private lazy var checkmarkLabel = UILabel().then {
        $0.adjustsFontSizeToFitWidth = true
        $0.font                      = .systemFont(ofSize: 32, weight: .semibold)
        $0.text                      = "✓"
        $0.textColor                 = .white
        $0.textAlignment             = .center
        $0.isSafelyHidden            = true
    }
    
    private lazy var colorScheme: ColorScheme = .colorScheme { _ in .systemBlue }
    
    private(set) lazy var highlightView = HighlightView(
        frame: bounds,
        name: elementName,
        colorScheme: colorScheme,
        reference: ViewHierarchyReference(root: self)
    ).then {
        $0.verticalAlignmentOffset = activityIndicator.frame.height * 2 / 3
    }
    
//    var currentOperation: Operation? {
//        didSet {
//            accessibilityIdentifier = currentOperation?.name
//        }
//    }
    
    override var accessibilityIdentifier: String? {
        didSet {
            if let name = accessibilityIdentifier {
                highlightView.name = name
            }
        }
    }
    
    // MARK: - Setup
    
    override func setup() {
        super.setup()
        
        isUserInteractionEnabled = false
        
        backgroundColor = ViewHierarchyColorScheme.default.color(for: activityIndicator)
        
        installView(checkmarkLabel, .centerXY)
        
        installView(activityIndicator, .margins(8))
        
        installView(highlightView, .autoResizingMask)
        
        addInspectorViews()
        
        checkmarkLabel.widthAnchor.constraint(equalTo: activityIndicator.widthAnchor).isActive = true
        
        checkmarkLabel.heightAnchor.constraint(equalTo: activityIndicator.heightAnchor).isActive = true
    }
    
    func addInspectorViews() {
        for element in subviews where element.canHostInspectorView {
            element.layer.cornerRadius = layer.cornerRadius / 2
            
            let inspectorView = WireframeView(
                frame: element.bounds,
                reference: ViewHierarchyReference(root: element),
                color: .white
            )
            
            element.installView(inspectorView, .autoResizingMask, .onTop)
        }
        
        installView(highlightView, .autoResizingMask)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        highlightView.labelWidthConstraint = nil
        
        layer.cornerRadius = frame.height / .pi
    }
    
    func done() {
        activityIndicator.stopAnimating()
        
        checkmarkLabel.isSafelyHidden = false
    }
    
    func prepareForReuse() {
//        currentOperation = nil
        
        activityIndicator.startAnimating()
        
        checkmarkLabel.isSafelyHidden = true
        
        alpha = 1
    }
}

// MARK: - Loader Pool Management

//extension LoaderView {
//
//    static var sharedPool: [UIView: LoaderView] = [:]
//
//    static func dequeueLoaderView(
//        for operation: Operation,
//        in presenter: UIView
//    ) -> LoaderView {
//
//        let loaderView: LoaderView = {
//
//            guard let cachedView = sharedPool[presenter] else {
//                return LoaderView()
//            }
//
//            cachedView.layer.removeAllAnimations()
//
//            cachedView.prepareForReuse()
//
//            return cachedView
//
//        }()
//
//        loaderView.currentOperation = operation
//
//        sharedPool[presenter] = loaderView
//
//        return loaderView
//    }
//
//}
