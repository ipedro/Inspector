//
//  HierarchyInspectableProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public protocol HierarchyInspectableProtocol {
    
    var window: UIWindow? { get }
    
    var hierarchyInspectorManager: HierarchyInspector.Manager? { get }
    
    var hierarchyInspectorLayers: [ViewHierarchyLayer] { get }
    
    var hierarchyInspectorColorScheme: ViewHierarchyColorScheme { get }
    
    var hierarchyInspectorElementLibraries: [HierarchyInspectorElementLibraryProtocol] { get }
}

// MARK: - Default Values

public extension HierarchyInspectableProtocol {
    var hierarchyInspectorLayers: [ViewHierarchyLayer] { [] }
    
    var hierarchyInspectorColorScheme: ViewHierarchyColorScheme { .default }
    
    var hierarchyInspectorElementLibraries: [HierarchyInspectorElementLibraryProtocol] { [] }
    
    func presentHierarchyInspector(animated: Bool) {
        window?.hierarchyInspectorManager?.present(animated: animated)
    }
}
