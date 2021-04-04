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
    
    #warning("move header style to ElementInspector.appearance")
    private(set) lazy var elementNameLabel = SectionHeader(.title3, text: nil, withTraits: .traitBold).then {
        $0.contentView.directionalLayoutMargins = .zero
    }
    
    #warning("move text style to ElementInspector.appearance")
    private(set) lazy var elementDescriptionLabel =  UILabel(.caption2, textColor: ElementInspector.appearance.secondaryTextColor, numberOfLines: 0)
    
    private(set) lazy var headerContentView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            elementNameLabel,
            elementDescriptionLabel
        ],
        spacing: ElementInspector.appearance.verticalMargins / 2,
        margins: ElementInspector.appearance.margins
    )
    
    private(set) lazy var scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.keyboardDismissMode = .onDrag
    }
    
    #if swift(>=5.0)
    @available(iOS 13.0, *)
    private lazy var hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
    #endif
    
    private(set) var isPointerInUse = false {
        didSet {
            delegate?.attributesInspectorViewCode(self, isPointerInUse: isPointerInUse)
        }
    }
    
    override func setup() {
        super.setup()
        
        scrollView.installView(contentView)
        
        installView(scrollView)
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        contentView.addArrangedSubview(headerContentView)
        
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        contentView.directionalLayoutMargins = .margins(bottom: 30)
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
