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
    
    private lazy var elementInspectorViewController: ElementInspectorViewController = {
        let viewController = ElementInspectorViewController.create(
            viewModel: ElementInspectorViewModel(
                reference: reference
                )
        )

        return viewController
    }()
    
    private lazy var navigationController = UINavigationController(
        rootViewController: elementInspectorViewController
    ).then {
        $0.modalPresentationStyle = .popover
        $0.popoverPresentationController?.sourceView = sourceView
        
        if #available(iOS 13.0, *) {
            $0.view.backgroundColor = .systemBackground
        } else {
            $0.view.backgroundColor = .groupTableViewBackground
        }
    }
    
    func start() -> UINavigationController {
        navigationController
    }
}
