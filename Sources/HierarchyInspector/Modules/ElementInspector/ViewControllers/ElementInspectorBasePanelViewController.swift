//
//  ElementInspectorPanelViewControllerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 15.10.20.
//

import UIKit

class ElementInspectorBasePanelViewController: UIViewController {
    private var needsLayout = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard needsLayout else {
            return
        }
        
        needsLayout = false
        
        debounce(#selector(updatePreferredContentSize), after: 0.1)
    }
    
    @objc func updatePreferredContentSize() {
        guard let self = self as? ElementInspectorPanelViewController else {
            return
        }
        
        preferredContentSize = self.calculatePreferredContentSize()
    }
}
