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
    func viewHierarchyListViewController(_ viewController: ElementViewHierarchyViewController, didSegueTo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference) {
        operationQueue.cancelAllOperations()
        
        addOperationToQueue(MainThreadOperation(name: "push hierarchy \(reference.displayName)", closure: { [weak self] in
            
            self?.pushElementInspector(with: reference, selectedPanel: .viewHierarchy, animated: true)
            
        }))
    }
    
    func viewHierarchyListViewController(_ viewController: ElementViewHierarchyViewController, didSelectInfo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference) {
        operationQueue.cancelAllOperations()
        
        addOperationToQueue(MainThreadOperation(name: "push info \(reference.displayName)", closure: { [weak self] in
            guard
                reference == rootReference,
                let topElementInspector = self?.navigationController.topViewController as? ElementInspectorViewController
            else {
                self?.pushElementInspector(with: reference, selectedPanel: .attributes, animated: true)
                return
            }
            
            topElementInspector.selectPanelIfAvailable(.attributes)
            
        }))
    }
    
    private func pushElementInspector(with reference: ViewHierarchyReference, selectedPanel: ElementInspectorPanel?, animated: Bool) {
        let elementInspectorViewController = Self.makeElementInspectorViewController(
            with: reference,
            in: viewHierarchySnapshot,
            showDismissBarButton: false,
            selectedPanel: selectedPanel,
            elementLibraries: viewHierarchySnapshot.elementLibraries,
            delegate: self
        )
        
        navigationController.pushViewController(elementInspectorViewController, animated: animated)
    }
}
