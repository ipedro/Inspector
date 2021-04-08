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
        guard
            let hostViewController = hostViewController,
            let window = hostViewController.view.window
        else {
            return
        }
        
        asyncOperation { [weak self] in
            guard let self = self else {
                return
            }
            
            let windowReference = ViewHierarchyReference(root: window)
            
            let coordinator = ElementInspectorCoordinator(reference: reference, rootReference: windowReference).then {
                $0.delegate = self
            }
            
            self.elementInspectorCoordinator = coordinator
            
            let elementInspectorNavigationController = coordinator.start()
            elementInspectorNavigationController.popoverPresentationController?.sourceView = sourceView
            
            hostViewController.present(elementInspectorNavigationController, animated: animated)
        }
    }

}
