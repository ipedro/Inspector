//
//  LayerManagerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public protocol HierarchyLayerManagerProtocol {
    func installLayer(_ layer: ViewHierarchyLayer)
    
    func removeLayer(_ layer: ViewHierarchyLayer)
    
    func installAllLayers()
    
    func removeAllLayers()
}
