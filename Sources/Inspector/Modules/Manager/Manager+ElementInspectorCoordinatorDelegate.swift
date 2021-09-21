//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

extension Manager: ElementInspectorCoordinatorDelegate {
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, showHighlightViewsVisibilityOf reference: ViewHierarchyReference) {
        for child in children {
            if let viewHierarchyCoordinator = child as? ViewHierarchyCoordinator {
                viewHierarchyCoordinator.toggleHighlightViews(visibility: true, inside: reference)
            }
        }
    }

    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, hideHighlightViewsVisibilityOf reference: ViewHierarchyReference) {
        for child in children {
            if let viewHierarchyCoordinator = child as? ViewHierarchyCoordinator {
                viewHierarchyCoordinator.toggleHighlightViews(visibility: false, inside: reference)
            }
        }
    }

    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, didFinishWith reference: ViewHierarchyReference) {
        for child in children {
            if let viewHierarchyCoordinator = child as? ViewHierarchyCoordinator {
                viewHierarchyCoordinator.toggleHighlightViews(visibility: true, inside: reference)
            }
        }

        removeChild(coordinator)
    }
}

extension Manager {
    func presentElementInspector(for reference: ViewHierarchyReference, animated: Bool, from sourceView: UIView?) {
        guard let snapshot = viewHierarchyCoordinator.currentSnapshot() else { return }

        let coordinator = ElementInspectorCoordinator(
            reference: reference,
            in: snapshot,
            from: sourceView
        ).then {
            $0.delegate = self
        }

        addChild(coordinator)

        hostViewController?.present(coordinator.start(), animated: animated)
    }
}
