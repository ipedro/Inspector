//
//  PropertyInspectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class PropertyInspectorViewCode: BaseView {
    
    #warning("move header style to ElementInspector.Appearance")
    private(set) lazy var elementNameLabel = SectionHeader(.title3, text: nil, bold: true).then {
        $0.contentView.directionalLayoutMargins = .zero
    }
    
    #warning("move text style to ElementInspector.Appearance")
    private(set) lazy var elementDescriptionLabel =  UILabel.init(.caption2, numberOfLines: 0).then {
        $0.alpha = 0.5
    }
    
    #warning("move vertical to ElementInspector.Appearance")
    private(set) lazy var headerContentView = UIStackView(
        axis: .vertical,
        arrangedSubviews: [
            elementNameLabel,
            elementDescriptionLabel
        ],
        spacing: 4,
        margins: ElementInspector.appearance.margins
    )
    
    private(set) lazy var scrollView = UIScrollView()
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(headerContentView)
        
        scrollView.installView(contentView)
        
        installView(scrollView)
        
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        contentView.directionalLayoutMargins = .margins(bottom: 30)
    }
}
