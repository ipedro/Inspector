//
//  HierarchyLayerConstructor.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

protocol HierarchyLayerConstructor {
    func isShowingLayer(_ layer: HierarchyInspector.Layer) -> Bool
    
    @discardableResult
    func create(layer: HierarchyInspector.Layer, for viewHierarchySnapshot: ViewHierarchySnapshot) -> Bool
    
    @discardableResult
    func destroy(layer: HierarchyInspector.Layer) -> Bool
    
    @discardableResult
    func destroyAllLayers() -> Bool
}
