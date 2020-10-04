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
