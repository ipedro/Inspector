//
//  ViewHierarchyLayersCoordinator.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

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
    
    func invalidate() {
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
