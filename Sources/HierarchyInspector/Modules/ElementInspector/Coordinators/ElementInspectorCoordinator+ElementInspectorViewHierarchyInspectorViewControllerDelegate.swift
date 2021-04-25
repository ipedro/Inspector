//
//  ElementInspectorCoordinator+ElementInspectorViewHierarchyInspectorViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

extension ElementInspectorCoordinator: ElementInspectorViewHierarchyInspectorViewControllerDelegate {
    func viewHierarchyListViewController(_ viewController: ElementViewHierarchyViewController, didSegueTo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference) {
        
        operationQueue.cancelAllOperations()
        
        addOperationToQueue(MainThreadOperation(name: "push hierarchy \(reference.displayName)", closure: { [weak self] in
            
            self?.pushElementInspector(with: reference, selectedPanel: .viewHierarchyInspector, animated: true)
            
        }))
    }
    
    func viewHierarchyListViewController(_ viewController: ElementViewHierarchyViewController, didSelectInfo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference) {
        
        operationQueue.cancelAllOperations()
        
        addOperationToQueue(MainThreadOperation(name: "push info \(reference.displayName)", closure: { [weak self] in
            guard
                reference == rootReference,
                let topElementInspector = self?.navigationController.topViewController as? ElementInspectorViewController
            else {
                self?.pushElementInspector(with: reference, selectedPanel: .attributesInspector, animated: true)
                return
            }
            
            topElementInspector.selectPanelIfAvailable(.attributesInspector)
            
        }))
    }
    
    private func pushElementInspector(with reference: ViewHierarchyReference, selectedPanel: ElementInspectorPanel?, animated: Bool) {
        
        let elementInspectorViewController = Self.makeElementInspectorViewController(
            with: reference,
            showDismissBarButton: false,
            selectedPanel: selectedPanel,
            delegate: self,
            inspectableElements: viewHierarchySnapshot.elementLibraries
        )
        
        navigationController.pushViewController(elementInspectorViewController, animated: animated)
    }
}
