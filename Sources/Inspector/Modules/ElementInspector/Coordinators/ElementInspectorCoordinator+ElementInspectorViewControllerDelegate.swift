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

extension ElementInspectorCoordinator: ElementInspectorPanelViewControllerDelegate {
    func elementInspectorViewController(_ viewController: ElementInspectorViewController,
                                        viewControllerFor panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController
    {
        switch panel {
        case .attributesInspector:
            return ElementAttributesInspectorViewController.create(
                viewModel: AttributesInspectorViewModel(
                    reference: reference,
                    snapshot: viewHierarchySnapshot
                )).then {
                $0.formDelegate = self
            }

        case .viewHierarchyInspector:
            return ElementViewHierarchyViewController.create(
                viewModel: ElementViewHierarchyInspectorViewModel(
                    reference: reference,
                    snapshot: viewHierarchySnapshot
                )
            ).then {
                $0.delegate = self
            }

        case .autoLayoutInspector:
            return ElementAutoLayoutInspectorViewController.create(
                viewModel: AutoLayoutInspectorViewModel(
                    reference: reference,
                    snapshot: viewHierarchySnapshot
                )
            ).then {
                $0.formDelegate = self
            }
        }
    }

    func elementInspectorViewControllerDidFinish(_ viewController: ElementInspectorViewController) {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}
