//
//  Manager+HierarchyInspectorCoordinatorDelegate.swift
//  
//
//  Created by Pedro on 11.04.21.
//

import UIKit

extension HierarchyInspector.Manager: HierarchyInspectorCoordinatorDelegate {
    func hierarchyInspectorCoordinator(_ coordinator: HierarchyInspectorCoordinator,
                                       didFinishWith reference: ViewHierarchyReference?) {
        
        hierarchyInspectorCoordinator = nil
        
        guard let reference = reference else {
            return
        }
        
        presentElementInspector(for: reference, animated: true, from: nil)
    }
}
