//
//  ElementInspectorPanelViewControllerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 15.10.20.
//

import UIKit

class ElementInspectorBasePanelViewController: UIViewController {
    
    // MARK: - Layout
    
    private var needsLayout = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard needsLayout else {
            return
        }
        
        needsLayout = false
        
        updatePreferredContentSize()
    }
    
    @objc
    func updatePreferredContentSize() {
        guard
            let self = self as? ElementInspectorPanelViewController,
            modalPresentationStyle == .popover
        else {
            return
        }
        
        preferredContentSize = self.calculatePreferredContentSize()
    }
}
