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
        
        case .attributesInspector:
            return AttributesInspectorViewController.create(viewModel: AttributesInspectorViewModel(reference: reference)).then {
                $0.delegate = self
            }
            
        case .viewHierarchyInspector:
            return ViewHierarchyInspectorViewController.create(viewModel: ViewHierarchyInspectorViewModel(reference: reference)).then {
                $0.delegate = self
            }
            
        case .sizeInspector:
            return SizeInspectorViewController()
        }
    }
    
    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController) {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}
