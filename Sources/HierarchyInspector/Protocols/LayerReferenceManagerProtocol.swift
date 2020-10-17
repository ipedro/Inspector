//
//  LayerReferenceManagerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 17.10.20.
//

import Foundation

protocol LayerReferenceManagerProtocol {
    var isShowingLayers: Bool { get }
    
    var activeLayers: [ViewHierarchyLayer] { get }
    
    var availableLayers: [ViewHierarchyLayer] { get }
    
    var populatedLayers: [ViewHierarchyLayer] { get }
    
    func updateLayerViews(to newValue: [ViewHierarchyReference: LayerView],
                          from oldValue: [ViewHierarchyReference: LayerView])
    
    func removeReferences(for removedLayers: Set<ViewHierarchyLayer>,
                          in oldValue: [ViewHierarchyLayer: [ViewHierarchyReference]])
    
    func addReferences(for newLayers: Set<ViewHierarchyLayer>,
                       with colorScheme: ColorScheme)
}
