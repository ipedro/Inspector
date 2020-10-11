//
//  PopoverNavigationController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

protocol PopoverNavigationControllerDelegate: AnyObject {
    func popoverNavigationControllerDidFinish(_ popoverNavigationController: PopoverNavigationController)
}

final class PopoverNavigationController: UINavigationController {
    weak var presentationDelegate: PopoverNavigationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = .systemPurple
        
        view.backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
        #endif
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        preferredContentSize = container.preferredContentSize
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard parent == nil else {
            return
        }
        
        presentationDelegate?.popoverNavigationControllerDidFinish(self)
    }
    
}
