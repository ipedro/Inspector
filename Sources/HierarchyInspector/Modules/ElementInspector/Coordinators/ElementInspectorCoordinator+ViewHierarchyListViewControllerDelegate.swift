//
//  ElementInspectorCoordinator+ViewHierarchyListViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

extension ElementInspectorCoordinator: ViewHierarchyListViewControllerDelegate {
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSegueTo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference) {
        
        operationQueue.cancelAllOperations()
        
        addOperationToQueue(MainThreadOperation(name: "push hierarchy \(reference.elementName)", closure: { [weak self] in
            
            self?.pushElementInspector(with: reference, selectedPanel: .viewHierarchy, animated: true)
            
        }))
    }
    
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSelectInfo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference) {
        
        operationQueue.cancelAllOperations()
        
        addOperationToQueue(MainThreadOperation(name: "push info \(reference.elementName)", closure: { [weak self] in
            guard
                reference == rootReference,
                let topElementInspector = self?.navigationController.topViewController as? ElementInspectorViewController
            else {
                self?.pushElementInspector(with: reference, selectedPanel: .propertyInspector, animated: true)
                return
            }
            
            topElementInspector.selectPanelIfAvailable(.propertyInspector)
            
        }))
    }
    
    private func pushElementInspector(with reference: ViewHierarchyReference, selectedPanel: ElementInspectorPanel?, animated: Bool) {
        
        let elementInspectorViewController = makeElementInspectorViewController(
            with: reference,
            showDismissBarButton: false,
            selectedPanel: selectedPanel
        )
        
        navigationController.pushViewController(elementInspectorViewController, animated: animated)
    }
}
