//
//  ElementInspectorNavigationController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 09.10.20.
//

import UIKit

final class ElementInspectorNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
        
    }
}
