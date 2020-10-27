//
//  ElementInspectorCoordinator+ElementInspectorViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

// MARK: - ElementInspectorViewControllerDelegate

extension ElementInspectorCoordinator: ElementInspectorViewControllerDelegate {
    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        viewControllerFor panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController {
        
        switch panel {
        
        case .propertyInspector:
            return PropertyInspectorViewController.create(viewModel: PropertyInspectorViewModel(reference: reference)).then {
                $0.delegate = self
            }
            
        case .viewHierarchy:
            return ViewHierarchyListViewController.create(viewModel: ViewHierarchyListViewModel(reference: reference)).then {
                $0.delegate = self
            }
            
        }
    }
    
    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController) {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}
