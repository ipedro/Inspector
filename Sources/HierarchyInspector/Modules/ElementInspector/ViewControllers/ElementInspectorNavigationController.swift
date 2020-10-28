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
        
        view.tintColor = ElementInspector.configuration.appearance.tintColor
        
        view.backgroundColor = ElementInspector.configuration.appearance.panelBackgroundColor
        
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
        #endif
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        // Async here is preventing weird popover behavior.
        DispatchQueue.main.async {
            self.preferredContentSize = container.preferredContentSize
        }
    }
    
}
