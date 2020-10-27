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
        
        Console.print(#function, view.frame)
        
        guard needsLayout else {
            return
        }
        
        needsLayout = false
        
        updatePreferredContentSize()
    }
    
    @objc
    func updatePreferredContentSize() {
        guard let self = self as? ElementInspectorPanelViewController else {
            return
        }
        
        preferredContentSize = self.calculatePreferredContentSize()
    }
}
