//
//  LayerManagerProtocol.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public protocol HierarchyLayerManagerProtocol: UIViewController {
    func installLayer(_ layer: HierarchyInspector.Layer, in viewHierarchy: [UIView])
    
    func removeLayer(_ layer: HierarchyInspector.Layer)
    
    func installAllLayers(in viewHierarchy: [UIView])
    
    func removeAllLayers()
}
