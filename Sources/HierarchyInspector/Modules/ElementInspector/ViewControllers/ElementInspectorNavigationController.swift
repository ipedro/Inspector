//
//  ElementInspectorNavigationController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

final class ElementInspectorNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = ElementInspector.appearance.tintColor
        
        view.backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        navigationBar.barStyle = .black
        
        addKeyCommand(UIViewController.dismissModalKeyCommand)
        
        becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool { true }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        // Async here is preventing weird popover behavior.
        DispatchQueue.main.async {
            self.preferredContentSize = container.preferredContentSize
        }
    }
    
}
