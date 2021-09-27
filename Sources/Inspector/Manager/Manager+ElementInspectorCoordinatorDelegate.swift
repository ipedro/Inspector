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
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator,
                                     didSelect reference: ViewHierarchyReference,
                                     with action: ViewHierarchyAction,
                                     from fromReference: ViewHierarchyReference) {

        if let panel = ElementInspectorPanel(rawValue: action) {
            startElementInspectorCoordinator(for: reference, with: panel, animated: true, from: reference.rootView)
        }
        else if viewHierarchyCoordinator?.canPerform(action: action) == true {
            viewHierarchyCoordinator?.perform(action: action, for: reference)
        }
    }

    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator,
                                     showHighlight: Bool,
                                     for reference: ViewHierarchyReference)
    {
        viewHierarchyCoordinator?.showHighlight(showHighlight, for: reference)
    }

    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator,
                                     didFinishInspecting reference: ViewHierarchyReference,
                                     with action: ElementInspectorDismissAction) {
        switch action {
        case .dismiss:
            removeChild(coordinator)
            coordinator.dismissPresentation(animated: true)

        case .stopInspecting:
            reset()
        }
    }
}

extension Manager {
    func startElementInspectorCoordinator(for view: UIView,
                                          with panel: ElementInspectorPanel?,
                                          animated: Bool,
                                          from sourceView: UIView?) {
        guard let elementLibraries = viewHierarchySnaphost?.elementLibraries else { return }

        let reference = ViewHierarchyReference(view, iconProvider: { elementLibraries.icon(for: $0) })

        startElementInspectorCoordinator(for: reference, with: panel, animated: animated, from: sourceView)
    }

    func startElementInspectorCoordinator(for reference: ViewHierarchyReference,
                                          with panel: ElementInspectorPanel?,
                                          animated: Bool,
                                          from sourceView: UIView?) {
        guard let snapshot = viewHierarchySnaphost else { return }

        let coordinator = ElementInspectorCoordinator(
            reference: reference,
            with: panel,
            in: snapshot,
            from: sourceView
        ).then {
            $0.delegate = self
        }

        addChild(coordinator)

        host?.window?.topPresentedViewController?.present(coordinator.start(), animated: animated)
    }
}
