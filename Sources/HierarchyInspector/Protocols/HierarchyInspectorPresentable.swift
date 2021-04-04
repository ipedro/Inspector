//
//  HierarchyInspectableProtocol+ActionSheetPresentation.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectorPresentable: HierarchyInspectableProtocol {
    
    var hierarchyInspectorManager: HierarchyInspector.Manager { get }
    
    var canPresentHierarchyInspector: Bool { get }
    
    func presentHierarchyInspector(animated: Bool)
    
}

public extension HierarchyInspectorPresentable {
    
    func presentHierarchyInspector(animated: Bool) {
        presentHierarchyInspector(animated: animated, isInspecting: false)
    }
    
}

// MARK: - ActionSheet Presentation

extension HierarchyInspectorPresentable {
    public var canPresentHierarchyInspector: Bool {
        presentingViewController is UIAlertController == false
    }
    
    func presentHierarchyInspector(animated: Bool, isInspecting: Bool) {
        guard
            canPresentHierarchyInspector,
            let viewHierarchySnapshot = hierarchyInspectorManager.viewHierarchySnapshot
        else {
            return
        }
        
        let viewController = HierarchyInspectorViewController.create(
            viewModel: HierarchyInspectorViewModel(
                layerActionGroupsProvider: { self.hierarchyInspectorManager.availableActions },
                snapshot: viewHierarchySnapshot
            )
        ).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.modalTransitionStyle   = .crossDissolve
        }
        
        present(viewController, animated: true)
    }
    
}
