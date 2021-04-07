//
//  Manager+HierarchyInspectorViewControllerDelegate.swift
//  
//
//  Created by Pedro Almeida on 07.04.21.
//

import UIKit

extension HierarchyInspector.Manager: HierarchyInspectorViewControllerDelegate {
    
    func hierarchyInspectorViewController(_ viewController: HierarchyInspectorViewController, didSelect viewHierarchyReference: ViewHierarchyReference) {
        presentElementInspector(
            for: viewHierarchyReference,
            animated: true,
            from: viewHierarchyReference.view
        )
    }
    
}
