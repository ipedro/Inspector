//
//  ElementSizeInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 28.10.20.
//

import UIKit

#warning("WIP")

final class ElementSizeInspectorViewController: ElementInspectorPanelViewController {
    func calculatePreferredContentSize() -> CGSize {
        #warning("implement")
        
        return preferredContentSize
    }
    
    private lazy var viewCode = ElementSizeInspectorViewCode()
    
    override func loadView() {
        view = viewCode
    }
}

final class ElementSizeInspectorViewCode: BaseView {
    
    private lazy var inspectorView = SizeInspectorView()
    
    override func setup() {
        super.setup()
        
        installView(inspectorView, priority: .required)
    }
}
