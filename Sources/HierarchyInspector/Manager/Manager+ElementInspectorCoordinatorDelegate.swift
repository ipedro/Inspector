//
//  Manager+ElementInspectorCoordinatorDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

// MARK: - ElementInspectorCoordinatorDelegate

extension HierarchyInspector.Manager: ElementInspectorCoordinatorDelegate {
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, showHighlightViewsVisibilityOf reference: ViewHierarchyReference) {
        viewHierarchyLayersCoordinator.hideAllHighlightViews(false, containedIn: reference)
    }
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, hideHighlightViewsVisibilityOf reference: ViewHierarchyReference) {
        viewHierarchyLayersCoordinator.hideAllHighlightViews(true, containedIn: reference)
    }
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, didFinishWith reference: ViewHierarchyReference) {
        viewHierarchyLayersCoordinator.hideAllHighlightViews(false, containedIn: reference)
        elementInspectorCoordinator = nil
    }
}

extension HierarchyInspector.Manager {
    
    func presentElementInspector(for reference: ViewHierarchyReference, animated: Bool, from sourceView: UIView?) {
        guard let windowHierarchySnapshot = windowHierarchySnapshot else {
            return
        }
        
        let coordinator = ElementInspectorCoordinator(
            reference: reference,
            inWindow: windowHierarchySnapshot,
            from: sourceView
        ).then {
            $0.delegate = self
        }
        
        elementInspectorCoordinator = coordinator
        
        hostViewController?.present(coordinator.start(), animated: animated)
    }

}
