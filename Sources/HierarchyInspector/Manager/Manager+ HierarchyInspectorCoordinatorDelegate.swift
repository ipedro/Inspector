//
//  Manager+HierarchyInspectorCoordinatorDelegate.swift
//  
//
//  Created by Pedro on 11.04.21.
//

import UIKit

extension HierarchyInspector.Manager: HierarchyInspectorCoordinatorDelegate {
    func hierarchyInspectorCoordinator(_ coordinator: HierarchyInspectorCoordinator,
                                       didFinishWith command: HierarchyInspectorCommand?) {
        
        hierarchyInspectorCoordinator = nil
        
        guard let command = command else {
            return
        }
        
        asyncOperation { [weak self] in
            switch command {
            case let .execute(closure):
                closure()
                
            case let .inspect(reference):
                self?.presentElementInspector(for: reference, animated: true, from: nil)
            }
        }
        
    }
}
