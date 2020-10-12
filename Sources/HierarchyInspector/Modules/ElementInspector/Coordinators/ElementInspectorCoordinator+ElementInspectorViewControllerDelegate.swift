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
                                        viewControllerForPanel panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> UIViewController {
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
}
