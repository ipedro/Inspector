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
    
}
