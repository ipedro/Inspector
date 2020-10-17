//
//  Manager+ViewHierarchyInspectorCoordinatorDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

// MARK: - ViewHierarchyInspectorCoordinatorDelegate

extension HierarchyInspector.Manager: ViewHierarchyInspectorCoordinatorDelegate {
    func viewHierarchyInspectorCoordinator(_ coordinator: ViewHierarchyInspectorCoordinator, didSelect viewHierarchyReference: ViewHierarchyReference, from highlightView: HighlightView) {
        presentElementInspector(for: viewHierarchyReference, from: highlightView.labelContentView, animated: true)
    }
}
