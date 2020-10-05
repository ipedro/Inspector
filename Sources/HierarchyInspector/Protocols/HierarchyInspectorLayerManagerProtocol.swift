//
//  LayerManagerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public protocol HierarchyLayerManagerProtocol: NSObject {
    func installLayer(_ layer: HierarchyInspector.Layer)
    
    func removeLayer(_ layer: HierarchyInspector.Layer)
    
    func installAllLayers()
    
    func removeAllLayers()
}
