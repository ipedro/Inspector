//
//  ElementInspectorCoordinator+ElementInspectorViewControllerDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

extension ElementInspectorCoordinator: ElementInspectorViewControllerDelegate {
    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        viewControllerFor panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController {
        
        switch panel {
        
        case .attributesInspector:
            return ElementAttributesInspectorViewController.create(viewModel: AttributesInspectorViewModel(reference: reference)).then {
                $0.delegate = self
            }
            
        case .viewHierarchyInspector:
            return ElementViewHierarchyViewController.create(viewModel: ElementViewHierarchyInspectorViewModel(reference: reference)).then {
                $0.delegate = self
            }
            
        case .sizeInspector:
            return ElementSizeInspectorViewController()
        }
    }
    
    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController) {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}
