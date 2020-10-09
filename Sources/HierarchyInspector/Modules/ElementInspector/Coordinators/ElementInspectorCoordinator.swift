//
//  ElementInspectorCoordinator.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ElementInspectorCoordinator {
    
    let reference: ViewHierarchyReference
    
    weak var sourceView: UIView?
    
    init(reference: ViewHierarchyReference, sourceView: UIView) {
        self.reference = reference
        self.sourceView = sourceView
    }
    
//    private lazy var viewController = ViewHierarchyListViewController.create(
//        viewModel: ViewHierarchyListViewModel(
//            reference: reference
//        )
//    )
    
    private lazy var viewController: ElementInspector.InspectorViewController = {
        
        let viewModel = ElementInspector.InspectorViewModel(reference: reference)

        let viewController = ElementInspector.InspectorViewController.create(viewModel: viewModel)

        return viewController
    }()
    
    private lazy var navigationController = ElementInspectorNavigationController(rootViewController: viewController).then {
        if #available(iOS 13.0, *) {
            $0.view.backgroundColor = .systemBackground
        } else {
            $0.view.backgroundColor = .groupTableViewBackground
        }
    }
    
    func start() -> UINavigationController {
//        if reference.flattenedViewHierarchy.count < 5 {
            navigationController.modalPresentationStyle                    = .popover
            navigationController.popoverPresentationController?.sourceView = sourceView
//            navigationController.popoverPresentationController?.delegate   = viewController
//        }
//        else {
//            navigationController.modalPresentationStyle = .formSheet
//        }
        
        return navigationController
    }
}
