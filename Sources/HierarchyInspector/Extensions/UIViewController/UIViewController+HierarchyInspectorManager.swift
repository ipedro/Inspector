//
//  UIViewController+HierarchyInspectorManager.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 25.04.21.
//

import UIKit

public extension UIViewController {
    
    var hierarchyInspectorManager: HierarchyInspector.Manager? {
        view.window?.hierarchyInspectorManager
    }
    
    // MARK: - Convenience
    
    var hierarchyInspectorBarButtonItem: UIBarButtonItem {
        UIBarButtonItem(
           title: "🧬",
           style: .plain,
           target: self,
           action: #selector(hierarchyInspectorBarButtonItemHandler)
       )
    }
    
    @objc private func hierarchyInspectorBarButtonItemHandler() {
        hierarchyInspectorManager?.present(animated: true)
    }

}
