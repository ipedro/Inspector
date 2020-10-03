//
//  HierarchyInspectableProtocol.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public protocol HierarchyInspectableProtocol: HierarchyLayerManagerProtocol {
    
    var hierarchyInspectorViews: [HierarchyInspector.Layer: [HierarchyInspectorView]] { get set }
    
    var hierarchyInspectorLayers: [HierarchyInspector.Layer] { get }
    
    var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme { get }
    
    var hierarchyInspectorSnapshot: HierarchyInspector.ViewHierarchySnapshot? { get set }
    
}

// MARK: - Default Values

public extension HierarchyInspectableProtocol {
    var hierarchyInspectorColorScheme: HierarchyInspector.ColorScheme { .default }
}

// MARK: - Internal Helpers

extension HierarchyInspectableProtocol {
    
    var populatedHierarchyInspectorLayers: [HierarchyInspector.Layer] {
        guard
            let hierarchyInspectorSnapshot = hierarchyInspectorSnapshot,
            Date() <= hierarchyInspectorSnapshot.expiryDate
        else {
            print("[Hierarchy Inspector] \(String(describing: classForCoder)): fresh calculation")
            let snapshot = HierarchyInspector.ViewHierarchySnapshot(
                populatedHirerchyLayers: hierarchyInspectorLayers.filter { $0.filter(viewHierarchy: view.inspectableViewHierarchy).isEmpty == false }
            )
            
            self.hierarchyInspectorSnapshot = snapshot
            
            return snapshot.populatedHirerchyLayers
        }
        
        return hierarchyInspectorSnapshot.populatedHirerchyLayers
    }
    
    // TODO: rename to `async(_:)`
    func performAsyncOperation(_ operation: @escaping () -> Void) {
        let window = view.window
        
        window?.showActivityIndicator()
        
        DispatchQueue.main.async {
            operation()
            
            window?.removeActivityIndicator()
        }
    }
    
    func insert(_ inspectorView: View, for layer: HierarchyInspector.Layer, in element: HierarchyInspectableView, onTop: Bool) {
        element.installView(inspectorView, position: .top) // TODO: make not set margins
        
        var views = hierarchyInspectorViews[layer] ?? []
        
        views.append(inspectorView)
        
        hierarchyInspectorViews[layer] = views
    }
}
