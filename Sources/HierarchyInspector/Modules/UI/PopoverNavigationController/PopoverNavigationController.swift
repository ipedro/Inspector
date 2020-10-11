//
//  PopoverNavigationController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.10.20.
//

import UIKit

final class PopoverNavigationController: UINavigationController {
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        preferredContentSize = container.preferredContentSize
    }
    
}
