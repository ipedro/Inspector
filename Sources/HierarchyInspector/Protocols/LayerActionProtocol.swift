//
//  LayerActionProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 17.10.20.
//

import Foundation

protocol LayerActionProtocol {
    func layerActions(for snapshot: ViewHierarchySnapshot) -> ActionGroup
    
    func otherActions(for snapshot: ViewHierarchySnapshot) -> ActionGroup
    
    func layerAction(_ layer: ViewHierarchyLayer, isEmpty: Bool) -> Action
}
