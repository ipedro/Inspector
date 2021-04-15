//
//  HierarchyInspectableViewControllerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public protocol HierarchyInspectableViewControllerProtocol: UIViewController {
    
    var hierarchyInspectorLayers: [ViewHierarchyLayer] { get }
    
    var hierarchyInspectorColorScheme: ViewHierarchyColorScheme { get }
    
    var hierarchyInspectorElements: [HierarchyInspectorElementLibraryProtocol] { get }
}

// MARK: - Default Values

public extension HierarchyInspectableViewControllerProtocol {
    var hierarchyInspectorColorScheme: ViewHierarchyColorScheme { .default }
}

// MARK: - View Controller Hierarchy

extension HierarchyInspectableViewControllerProtocol {
    
    var availableLayers: [ViewHierarchyLayer] {
        var layers = hierarchyInspectorLayers
        layers.append(.internalViews)
        layers.append(.allViews)
        
        return layers.uniqueValues
    }
    
    var availableElementLibraries: [HierarchyInspectorElementLibraryProtocol] {
        var elements = [HierarchyInspectorElementLibraryProtocol]()
        elements.append(contentsOf: hierarchyInspectorElements)
        elements.append(contentsOf: UIKitElementLibrary.standard)
        
        return elements
    }
    
    var topMostContainerViewController: HierarchyInspectableViewControllerProtocol {
        var topController: HierarchyInspectableViewControllerProtocol = self
        
        while topController.containerViewControllers.count > 1 {
            guard let vc = topController.containerViewControllers.first else {
                break
            }
            
            topController = vc
        }
        
        return topController
    }
    
    var containerViewControllers: [HierarchyInspectableViewControllerProtocol] {
        [
            splitViewController,
            tabBarController,
            navigationController,
            self
        ].compactMap { $0 as? HierarchyInspectableViewControllerProtocol }
    }
}
