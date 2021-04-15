//
//  HierarchyInspectableProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public protocol HierarchyInspectableProtocol: UIViewController {
    
    var hierarchyInspectorLayers: [ViewHierarchyLayer] { get }
    
    var hierarchyInspectorColorScheme: ViewHierarchyColorScheme { get }
    
    var hierarchyInspectorElements: [HierarchyInspectorElementLibraryProtocol] { get }
}

// MARK: - Default Values

public extension HierarchyInspectableProtocol {
    var hierarchyInspectorColorScheme: ViewHierarchyColorScheme { .default }
}

// MARK: - View Controller Hierarchy

extension HierarchyInspectableProtocol {
    
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
