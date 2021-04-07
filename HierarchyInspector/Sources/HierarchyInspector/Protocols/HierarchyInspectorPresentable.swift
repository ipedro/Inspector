//
//  HierarchyInspectableProtocol+ActionSheetPresentation.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectorPresentable: HierarchyInspectableProtocol {
    
    var hierarchyInspectorManager: HierarchyInspector.Manager { get }
    
    func presentHierarchyInspector(animated: Bool)
    
}

// MARK: - ActionSheet Presentation

public extension HierarchyInspectorPresentable {
    func presentHierarchyInspector(animated: Bool) {
        hierarchyInspectorManager.present(animated: animated)
    }
}
