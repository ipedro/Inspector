//
//  SizeInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 28.10.20.
//

import UIKit

final class SizeInspectorViewController: ElementInspectorPanelViewController {
    func calculatePreferredContentSize() -> CGSize {
        #warning("implement")
        
        return preferredContentSize
    }
    
    private lazy var viewCode = SizeInspectorViewCode()
    
    override func loadView() {
        view = viewCode
    }
}

final class SizeInspectorViewCode: BaseView {
    
    private lazy var inspectorView = SizeInspectorView()
    
    override func setup() {
        super.setup()
        
        installView(inspectorView, priority: .required)
    }
}
