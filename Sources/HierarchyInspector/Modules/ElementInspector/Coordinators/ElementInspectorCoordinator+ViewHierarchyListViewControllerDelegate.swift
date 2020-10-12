//
//  ElementInspectorCoordinator+ViewHierarchyListViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

extension ElementInspectorCoordinator: ViewHierarchyListViewControllerDelegate {
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSegueTo reference: ViewHierarchyReference) {
        let elementInspectorViewController = makeElementInspectorViewController(with: reference, showDismissBarButton: false, selectedPanel: .viewHierarchy)
        
        navigationController.pushViewController(elementInspectorViewController, animated: true)
    }
    
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSelectInfo reference: ViewHierarchyReference) {
        let elementInspectorViewController = makeElementInspectorViewController(with: reference, showDismissBarButton: false, selectedPanel: .propertyInspector)
        
        navigationController.pushViewController(elementInspectorViewController, animated: true)
    }
}
