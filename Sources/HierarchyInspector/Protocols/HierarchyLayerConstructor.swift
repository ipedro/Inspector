//
//  HierarchyLayerConstructor.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

protocol HierarchyLayerConstructor {
    func isShowingLayer(_ layer: ViewHierarchyLayer) -> Bool
    
    @discardableResult
    func create(layer: ViewHierarchyLayer, for viewHierarchySnapshot: ViewHierarchySnapshot) -> Bool
    
    @discardableResult
    func destroy(layer: ViewHierarchyLayer) -> Bool
    
    @discardableResult
    func destroyAllLayers() -> Bool
}
