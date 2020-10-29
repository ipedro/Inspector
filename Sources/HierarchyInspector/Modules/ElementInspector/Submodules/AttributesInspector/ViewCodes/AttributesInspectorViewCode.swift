//
//  AttributesInspectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

protocol AttributesInspectorViewCodeDelegate: AnyObject {
    func attributesInspectorViewCode(_ viewCode: AttributesInspectorViewCode, isPointerInUse: Bool)
}

final class AttributesInspectorViewCode: BaseView {
    weak var delegate: AttributesInspectorViewCodeDelegate?
    
    #warning("move header style to ElementInspector.configuration.appearance")
    private(set) lazy var elementNameLabel = SectionHeader(.title3, text: nil, withTraits: .traitBold).then {
        $0.contentView.directionalLayoutMargins = .zero
    }
    
    #warning("move text style to ElementInspector.configuration.appearance")
    private(set) lazy var elementDescriptionLabel =  UILabel(.caption2, numberOfLines: 0).then {
        $0.alpha = 0.5
    }
    
    private(set) lazy var headerContentView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            elementNameLabel,
            elementDescriptionLabel
        ],
        spacing: ElementInspector.configuration.appearance.verticalMargins / 2,
        margins: ElementInspector.configuration.appearance.margins
    )
    
    private(set) lazy var scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.keyboardDismissMode = .onDrag
    }
    
    @available(iOS 13.0, *)
    private lazy var hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
    
    private(set) var isPointerInUse = false {
        didSet {
            delegate?.attributesInspectorViewCode(self, isPointerInUse: isPointerInUse)
        }
    }
    
    override func setup() {
        super.setup()
        
        scrollView.installView(contentView)
        
        installView(scrollView)
        
        backgroundColor = ElementInspector.configuration.appearance.panelBackgroundColor
        
        contentView.addArrangedSubview(headerContentView)
        
        let widthConstraint = contentView.widthAnchor.constraint(equalTo: widthAnchor).then {
            $0.priority = .defaultHigh
        }
        
        widthConstraint.isActive = true
        
        contentView.directionalLayoutMargins = .margins(bottom: 30)
    }
    
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
}
