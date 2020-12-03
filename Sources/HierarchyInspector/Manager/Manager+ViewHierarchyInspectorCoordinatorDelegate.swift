//
//  Manager+ViewHierarchyLayersCoordinatorDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

// MARK: - ViewHierarchyLayersCoordinatorDelegate

extension HierarchyInspector.Manager: ViewHierarchyLayersCoordinatorDelegate {
    func viewHierarchyLayersCoordinator(_ coordinator: ViewHierarchyLayersCoordinator, didSelect viewHierarchyReference: ViewHierarchyReference, from highlightView: HighlightView) {
        presentElementInspector(for: viewHierarchyReference, animated: true, from: highlightView.labelContentView)
    }
}
