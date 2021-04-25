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
        viewHierarchyLayersCoordinator.toggleHighlightViews(visibility: true, inside: reference)
    }
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, hideHighlightViewsVisibilityOf reference: ViewHierarchyReference) {
        viewHierarchyLayersCoordinator.toggleHighlightViews(visibility: false, inside: reference)
    }
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, didFinishWith reference: ViewHierarchyReference) {
        viewHierarchyLayersCoordinator.toggleHighlightViews(visibility: true, inside: reference)
        elementInspectorCoordinator = nil
    }
}

extension HierarchyInspector.Manager {
    
    func presentElementInspector(for reference: ViewHierarchyReference, animated: Bool, from sourceView: UIView?) {
        guard let viewHierarchySnapshot = viewHierarchySnapshot else {
            return
        }
        
        let coordinator = ElementInspectorCoordinator(reference: reference, in: viewHierarchySnapshot, from: sourceView)
        coordinator.delegate = self
        
        elementInspectorCoordinator = coordinator
        
        hostViewController?.present(coordinator.start(), animated: animated)
    }

}
