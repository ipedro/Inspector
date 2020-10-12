//
//  ElementInspectorCoordinator+ViewHierarchyListViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

extension ElementInspectorCoordinator: ViewHierarchyListViewControllerDelegate {
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSelect reference: ViewHierarchyReference) {
        let elementInspectorViewController = makeElementInspectorViewController(with: reference, showDismissBarButton: false)
        
        navigationController.pushViewController(elementInspectorViewController, animated: true)
    }
}
