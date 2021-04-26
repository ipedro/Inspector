//
//  ElementInspectorNavigationController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

protocol ElementInspectorNavigationControllerDismissDelegate: AnyObject {
    func elementInspectorNavigationControllerDidFinish(_ navigationController: ElementInspectorNavigationController)
}

final class ElementInspectorNavigationController: UINavigationController {
    
    weak var dismissDelegate: ElementInspectorNavigationControllerDismissDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = ElementInspector.appearance.tintColor
        
        view.backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        navigationBar.barStyle = .black
        
        addKeyCommand(dismissModalKeyCommand(action: #selector(finish)))
        
        becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool { true }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        // Async here is preventing weird popover behavior.
        DispatchQueue.main.async {
            self.preferredContentSize = container.preferredContentSize
        }
    }
    
    @objc private func finish() {
        dismissDelegate?.elementInspectorNavigationControllerDidFinish(self)
    }
    
}
