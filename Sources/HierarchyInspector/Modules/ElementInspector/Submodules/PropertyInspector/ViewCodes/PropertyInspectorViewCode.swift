//
//  PropertyInspectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class PropertyInspectorViewCode: BaseView {
    
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
}
