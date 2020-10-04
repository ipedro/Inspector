//
//  Manager.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

extension HierarchyInspector {
    public final class Manager: NSObject {
        
        public init(host: HierarchyInspectableProtocol) {
            self.host = host
        }
        
        weak private var host: HierarchyInspectableProtocol?
        
        var inspectorViewsForLayers: [HierarchyInspector.Layer: [HierarchyInspectorView]] = [:] {
            didSet {
                for (oldLayer, oldViews) in oldValue where inspectorViewsForLayers.keys.contains(oldLayer) == false {
                    oldViews.forEach { $0.removeFromSuperview() }
                }
            }
        }
        
        var viewHierarchySpapshot: ViewHierarchySnapshot {
            guard
                let cachedSpapshot = cachedViewHierarchySpapshot,
                Date() <= cachedSpapshot.expiryDate
            else {
                
                let start = Date()
                let snapshot = ViewHierarchySnapshot(
                    availableLayers: _availableLayers,
                    populatedLayers: _populatedLayers,
                    activeLayers: activeLayers
                )
                
                cachedViewHierarchySpapshot = snapshot
                
                print("[Hierarchy Inspector] \(String(describing: classForCoder)): calculated snapshot in \(Date().timeIntervalSince(start)) s")
                
                return snapshot
            }
            
            return cachedSpapshot
        }
        
        private var cachedViewHierarchySpapshot: ViewHierarchySnapshot?
        
        public var isShowingLayers: Bool {
            inspectorViewsForLayers.keys.isEmpty == false
        }
        
        private(set) lazy var operationQueue = OperationQueue()
        
        deinit {
            invalidate()
        }
        
        func invalidate() {
            inspectorViewsForLayers.removeAll()
            
            host = nil
            
            operationQueue.cancelAllOperations()
        }
        
        struct Operation {
            let name: String
            let closure: Closure
        }
        
        func async(operation name: String, execute closure: @escaping Closure) {
            async(operation: Operation(name: name, closure: closure), in: hostViewController?.view.window)
        }
        
        #warning("TODO: migrate to Foundation OperationQueue")
        private func async(operation: Operation, in window: UIWindow?) {
            window?.showActivityIndicator(for: operation)
            
            DispatchQueue.main.async {
                operation.closure()
                
                window?.removeActivityIndicator()
            }
        }
    }
}

// MARK: - Layers Hierarchy

extension HierarchyInspector.Manager {
    
    var activeLayers: [HierarchyInspector.Layer] {
        inspectorViewsForLayers.compactMap { dict -> HierarchyInspector.Layer? in
            guard dict.value.isEmpty == false else {
                return nil
            }
            
            return dict.key
        }
    }
    
    var availableLayers: [HierarchyInspector.Layer] {
        viewHierarchySpapshot.availableLayers
    }
    
    var populatedLayers: [HierarchyInspector.Layer] {
        viewHierarchySpapshot.populatedLayers
    }
    
    private var _availableLayers: [HierarchyInspector.Layer] {
        hostViewController?.hierarchyInspectorLayers.uniqueValues ?? [.allViews]
    }
    
    private var _populatedLayers: [HierarchyInspector.Layer] {
        _availableLayers.filter {
            $0.filter(viewHierarchy: inspectableViewHierarchy).isEmpty == false
        }
    }
}

// MARK: - ViewController Hierarchy

extension HierarchyInspector.Manager {
    var hostViewController: HierarchyInspectableProtocol? {
        hostViewControllerHierarchy.first
    }
    
    var hostViewControllerHierarchy: [HierarchyInspectorPresentable] {
        [
            host?.splitViewController,
            host?.tabBarController,
            host?.navigationController,
            host
        ].compactMap { $0 as? HierarchyInspectorPresentable }
    }
    
    var inspectableViewHierarchy: [HierarchyInspectableView] {
        hostViewControllerHierarchy.first?.view.inspectableViewHierarchy ?? []
    }
}
