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
    func elementInspectorFormPanelViewController(_ viewController: ElementInspectorViewController,
                                        viewControllerFor panel: ElementInspectorPanel,
                                        with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController
    {
        panelController(for: panel, with: reference)
    }

    func panelController(for panel: ElementInspectorPanel, with reference: ViewHierarchyReference) -> ElementInspectorPanelViewController {
        switch panel {
        case .preview:
            return ElementPreviewPanelViewController.create(
                viewModel: ElementPreviewPanelViewModel(
                    reference: reference,
                    isLiveUpdating: true
                )
            ).then {
                $0.delegate = self
            }
        case .attributes:
            return ElementAttributesPanelViewController.create(
                viewModel: ElementAttributesPanelViewModel(
                    reference: reference,
                    snapshot: viewHierarchySnapshot
                )
            ).then {
                $0.formDelegate = self
            }

        case .children:
            return ElementChildrenPanelViewController.create(
                viewModel: ElementChildrenPanelViewModel(
                    reference: reference,
                    snapshot: viewHierarchySnapshot
                )
            ).then {
                $0.delegate = self
            }

        case .size:
            return ElementSizePanelViewController.create(
                viewModel: ElementSizePanelViewModel(reference: reference)
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
