//
//  ElementInspectorCoordinator+ViewHierarchyListViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

extension ElementInspectorCoordinator: ViewHierarchyListViewControllerDelegate {
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSegueTo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference) {
        let elementInspectorViewController = makeElementInspectorViewController(with: reference, showDismissBarButton: false, selectedPanel: .viewHierarchy)
        
        navigationController.pushViewController(elementInspectorViewController, animated: true)
    }
    
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSelectInfo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference) {
        guard
            reference == rootReference,
            let topElementInspector = navigationController.topViewController as? ElementInspectorViewController
        else {
            let elementInspectorViewController = makeElementInspectorViewController(with: reference, showDismissBarButton: false, selectedPanel: .propertyInspector)
            
            return navigationController.pushViewController(elementInspectorViewController, animated: true)
        }
        
        topElementInspector.selectPanelIfAvailable(.propertyInspector)
    }
}
