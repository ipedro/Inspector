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
    
    private lazy var viewController = ViewHierarchyListViewController.create(
        viewModel: ViewHierarchyListViewModel(
            reference: reference
        )
    )
    
    private lazy var navigationController = UINavigationController(rootViewController: viewController).then {
        if #available(iOS 13.0, *) {
            $0.view.backgroundColor = .systemBackground
            $0.overrideUserInterfaceStyle = .dark
        } else {
            $0.view.backgroundColor = .white
        }
    }
    
    func start() -> UINavigationController {
        if reference.flattenedViewHierarchy.count < 5 {
            navigationController.modalPresentationStyle                    = .popover
            navigationController.popoverPresentationController?.sourceView = sourceView
            navigationController.popoverPresentationController?.delegate   = viewController
        }
        else {
            navigationController.modalPresentationStyle = .formSheet
        }
        
        return navigationController
    }
}
