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

protocol ViewHierarchyLayersCoordinatorDelegate: AnyObject {
    
    func viewHierarchyLayersCoordinator(_ coordinator: ViewHierarchyLayersCoordinator,
                                        didSelect viewHierarchyReference: ViewHierarchyReference,
                                        from highlightView: HighlightView)
    
}

protocol ViewHierarchyLayersCoordinatorDataSource: AnyObject {
    
    var viewHierarchySnapshot: ViewHierarchySnapshot? { get }
    
    var viewHierarchyWindow: UIWindow? { get }
    
    var viewHierarchyColorScheme: ViewHierarchyColorScheme { get }
    
}

final class ViewHierarchyLayersCoordinator: Create {
    
    weak var delegate: ViewHierarchyLayersCoordinatorDelegate?
    
    weak var dataSource: ViewHierarchyLayersCoordinatorDataSource?
    
    let operationQueue = OperationQueue.main
    
    var wireframeViews: [ViewHierarchyReference: WireframeView] = [:] {
        didSet {
            updateLayerViews(to: wireframeViews, from: oldValue)
        }
    }
    
    var highlightViews: [ViewHierarchyReference: HighlightView] = [:] {
        didSet {
            updateLayerViews(to: highlightViews, from: oldValue)
        }
    }
    
    var visibleReferences: [ViewHierarchyLayer: [ViewHierarchyReference]] = [:] {
        didSet {
            let layers        = Set<ViewHierarchyLayer>(visibleReferences.keys)
            let oldLayers     = Set<ViewHierarchyLayer>(oldValue.keys)
            let newLayers     = layers.subtracting(oldLayers)
            let removedLayers = oldLayers.subtracting(layers)
            
            removeReferences(for: removedLayers, in: oldValue)
            
            guard let colorScheme = dataSource?.viewHierarchyColorScheme else {
                return
            }
            
            addReferences(for: newLayers, with: colorScheme)
        }
    }
    
    func finish() {
        visibleReferences.removeAll()
        wireframeViews.removeAll()
        highlightViews.removeAll()
    }
    
}

// MARK: - HighlightViewDelegate

extension ViewHierarchyLayersCoordinator: HighlightViewDelegate {
    
    func highlightView(_ highlightView: HighlightView, didTapWith reference: ViewHierarchyReference) {
        delegate?.viewHierarchyLayersCoordinator(self, didSelect: reference, from: highlightView)
    }
    
}
