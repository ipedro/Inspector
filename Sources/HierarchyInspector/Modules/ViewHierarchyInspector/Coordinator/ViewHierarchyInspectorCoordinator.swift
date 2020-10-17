//
//  ViewHierarchyInspectorCoordinator.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

protocol ViewHierarchyInspectorCoordinatorDelegate: AnyObject {
    func viewHierarchyInspectorCoordinator(_ coordinator: ViewHierarchyInspectorCoordinator,
                                           didSelect viewHierarchyReference: ViewHierarchyReference,
                                           from highlightView: HighlightView)
}

protocol ViewHierarchyInspectorCoordinatorDataSource: AnyObject {
    var viewHierarchySnapshot: ViewHierarchySnapshot? { get }
    
    var viewHierarchyWindow: UIWindow? { get }
    
    var viewHierarchyColorScheme: ViewHierarchyColorScheme { get }
}

final class ViewHierarchyInspectorCoordinator: Create {
    weak var delegate: ViewHierarchyInspectorCoordinatorDelegate?
    
    weak var dataSource: ViewHierarchyInspectorCoordinatorDataSource?
    
    let operationQueue = OperationQueue.main
    
    var wireframeViews: [ViewHierarchyReference: WireframeView] = [:] {
        didSet {
            updateLayerViews(to: wireframeViews, from: oldValue)
        }
    }
    
    var inspectorViews: [ViewHierarchyReference: HighlightView] = [:] {
        didSet {
            updateLayerViews(to: inspectorViews, from: oldValue)
        }
    }
    
    var visibleReferences: [ViewHierarchyLayer: [ViewHierarchyReference]] = [:] {
        didSet {
            let layers = Set<ViewHierarchyLayer>(visibleReferences.keys)
            let oldLayers = Set<ViewHierarchyLayer>(oldValue.keys)
            let newLayers = layers.subtracting(oldLayers)
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
        
        inspectorViews.removeAll()
    }
    
}

// MARK: - HighlightViewDelegate

extension ViewHierarchyInspectorCoordinator: HighlightViewDelegate {
    func highlightView(_ highlightView: HighlightView, didTapWith reference: ViewHierarchyReference) {
        delegate?.viewHierarchyInspectorCoordinator(self, didSelect: reference, from: highlightView)
    }
}
