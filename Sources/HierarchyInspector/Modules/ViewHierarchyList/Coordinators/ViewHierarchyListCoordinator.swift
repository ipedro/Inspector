//
//  ViewHierarchyListCoordinator.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListCoordinator {
    
    let reference: ViewHierarchyReference
    
    weak var sourceView: UIView?
    
    init(reference: ViewHierarchyReference, sourceView: UIView) {
        self.reference = reference
        self.sourceView = sourceView
    }
    
    func start() -> UINavigationController {
        let viewController = ViewHierarchyListViewController.create(
            viewModel: ViewHierarchyListViewModel(
                reference: reference
            )
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        if reference.flattenedViewHierarchy.count < 10 {
            navigationController.modalPresentationStyle = .popover
            navigationController.popoverPresentationController?.sourceView = sourceView
            navigationController.popoverPresentationController?.delegate = viewController
        }
        else {
            navigationController.modalPresentationStyle = .pageSheet
            if #available(iOS 13.0, *) {
                navigationController.view.backgroundColor = .systemGroupedBackground
            } else {
                navigationController.view.backgroundColor = .white
            }
        }
        
        return navigationController
    }
}
