//
//  HierarchyInspectorCoordinator.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 11.04.2021
//

import UIKit

protocol HierarchyInspectorCoordinatorDelegate: AnyObject {
    func hierarchyInspectorCoordinator(_ coordinator: HierarchyInspectorCoordinator,
                                       didFinishWith reference: ViewHierarchyReference?)
}

final class HierarchyInspectorCoordinator: NSObject {
    typealias ActionGroupsProvider = HierarchyInspectorViewModel.ActionGroupsProvider
    
    weak var delegate: HierarchyInspectorCoordinatorDelegate?
    
    let hierarchySnapshot: ViewHierarchySnapshot
    
    let actionGroupsProvider: ActionGroupsProvider
    
    private lazy var hierarchyInspectorViewController: HierarchyInspectorViewController = {
        let viewModel = HierarchyInspectorViewModel(
            actionGroupsProvider: actionGroupsProvider,
            snapshot: hierarchySnapshot
        )
        
        return HierarchyInspectorViewController.create(viewModel: viewModel).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.modalTransitionStyle = .crossDissolve
            $0.delegate = self
        }
    }()
    
    init(
        hierarchySnapshot: ViewHierarchySnapshot,
        actionGroupsProvider: @escaping ActionGroupsProvider
    ) {
        self.hierarchySnapshot = hierarchySnapshot
        self.actionGroupsProvider = actionGroupsProvider
    }
    
    func start() -> UIViewController {
        hierarchyInspectorViewController
    }
    
    func finish(with reference: ViewHierarchyReference? = nil) {
        hierarchyInspectorViewController.dismiss(animated: true) {
            self.delegate?.hierarchyInspectorCoordinator(self, didFinishWith: reference)
        }
    }    
}

// MARK: - HierarchyInspectorViewControllerDelegate

extension HierarchyInspectorCoordinator: HierarchyInspectorViewControllerDelegate {
    
    func hierarchyInspectorViewController(_ viewController: HierarchyInspectorViewController,
                                          didSelect viewHierarchyReference: ViewHierarchyReference) {
        finish(with: viewHierarchyReference)
    }
    
    func hierarchyInspectorViewControllerDidFinish(_ viewController: HierarchyInspectorViewController) {
        finish()
    }
}
