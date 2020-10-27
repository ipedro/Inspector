//
//  ElementInspectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class ElementInspectorViewCode: BaseView {
    
    private(set) lazy var segmentedControl = UISegmentedControl()
    
    private(set) lazy var inspectBarButtonItem = UIBarButtonItem(title: "🧬", style: .plain, target: nil, action: nil)
    
    private(set) lazy var dismissBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    private(set) lazy var emptyLabel = UILabel(
        .body,
        "No Element Inspector",
        textAlignment: .center
    ).then {
        $0.alpha = 0.5
    }
    
    override func setup() {
        super.setup()
        
        contentView.installView(emptyLabel, .margins(.zero), .onBottom)
    }
    
}
