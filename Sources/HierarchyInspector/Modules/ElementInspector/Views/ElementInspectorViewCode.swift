//
//  ElementInspectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class ElementInspectorViewCode: BaseView {
    
    private(set) lazy var segmentedControl = UISegmentedControl()
    
    private(set) lazy var dismissBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    private(set) lazy var emptyLabel = UILabel(
        .text("No Element Inspector"),
        .textStyle(.body),
        .textAlignment(.center),
        .viewOptions(
            .alpha(0.5)
        )
    )
    
    override func setup() {
        super.setup()
        
        contentView.installView(emptyLabel, .margins(.zero), position: .behind)
        
        installView(contentView, priority: .required)
    }
    
}
