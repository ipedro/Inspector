//
//  PropertyInspectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class PropertyInspectorViewCode: BaseView {
    
    private(set) lazy var scrollView = UIScrollView()
    
    override func setup() {
        super.setup()
        
        scrollView.installView(contentView)
        
        installView(scrollView)
        
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        contentView.spacing = 15
        
        contentView.directionalLayoutMargins = .margins(bottom: 30)
        
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        }
        else {
            backgroundColor = .white
        }
        
    }
}
