//
//  LayerManagerProtocol.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public protocol HierarchyLayerManagerProtocol: NSObject {
//    func installLayer(_ layer: HierarchyInspector.Layer, in viewHierarchy: [UIView])
    func installLayer(_ layer: HierarchyInspector.Layer)
    
    func removeLayer(_ layer: HierarchyInspector.Layer)
    
//    func installAllLayers(in viewHierarchy: [UIView])
    func installAllLayers()
    
    func removeAllLayers()
}
