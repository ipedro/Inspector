//
//  InspectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class InspectorViewCode: BaseView {
    
    private(set) lazy var scrollView = UIScrollView()
    
    override func setup() {
        super.setup()
        
        scrollView.installView(contentView)
        
        installView(scrollView)
        
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        contentView.spacing = 30
    }
}
