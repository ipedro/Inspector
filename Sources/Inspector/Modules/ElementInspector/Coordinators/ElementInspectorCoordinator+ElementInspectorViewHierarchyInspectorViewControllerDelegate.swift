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

extension ElementInspectorCoordinator: ElementInspectorViewHierarchyInspectorViewControllerDelegate {
    func viewHierarchyListViewController(_ viewController: ElementViewHierarchyViewController,
                                         didSelect reference: ViewHierarchyReference,
                                         with preferredPanel: ElementInspectorPanel?,
                                         from rootReference: ViewHierarchyReference) {
        operationQueue.cancelAllOperations()

        let pushOperation = MainThreadOperation(name: "Push \(reference.displayName)") { [weak self] in
            guard let self = self else { return }
            
            let selectedPanel: ElementInspectorPanel = {
                guard
                    let preferredPanel = preferredPanel,
                    ElementInspectorPanel.cases(for: reference).contains(preferredPanel)
                else {
                    return .preview
                }

                return preferredPanel
            }()

            let elementInspectorViewController = Self.makeElementInspectorViewController(
                with: reference,
                in: self.viewHierarchySnapshot,
                showDismissBarButton: false,
                selectedPanel: selectedPanel,
                elementLibraries: self.viewHierarchySnapshot.elementLibraries,
                delegate: self
            )

            self.navigationController.pushViewController(elementInspectorViewController, animated: true)
        }

        addOperationToQueue(pushOperation)
    }
}
