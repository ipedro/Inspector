//
//  HierarchyInspectableProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public protocol HierarchyInspectableProtocol: UIViewController {
    
    var hierarchyInspectorLayers: [HierarchyInspector.Layer] { get }
    
    var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme { get }
}

// MARK: - Default Values

public extension HierarchyInspectableProtocol {
    var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme { .default }
}

// MARK: - View Controller Hierarchy

#warning("WIP")
extension HierarchyInspectableProtocol {
    var topMostContainerViewController: HierarchyInspectableProtocol {
        var topController: HierarchyInspectableProtocol = self
        
        while topController.containerViewControllers.count > 1 {
            guard let vc = topController.containerViewControllers.first else {
                break
            }
            
            topController = vc
        }
        
        return topController
    }
    
    var containerViewControllers: [HierarchyInspectableProtocol] {
        [
            splitViewController,
            tabBarController,
            navigationController,
            self
        ].compactMap { $0 as? HierarchyInspectableProtocol }
    }
}
