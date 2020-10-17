//
//  ElementInspectorPanelViewControllerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 15.10.20.
//

import UIKit

class ElementInspectorBasePanelViewController: UIViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        debounce(#selector(updatePreferredContentSize), after: 0.15)
    }
    
    @objc func updatePreferredContentSize() {
        guard let self = self as? ElementInspectorPanelViewController else {
            return
        }
        
        self.preferredContentSize = self.calculatePreferredContentSize()
    }
}
