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
            self.hostViewController = host
        }
        
        weak private var hostViewController: HierarchyInspectableProtocol?
        
        var viewHierarchyReferences: [Layer: [ViewHierarchyReference]] = [:] {
            didSet {
                let layers        = Set<Layer>(viewHierarchyReferences.keys)
                let oldLayers     = Set<Layer>(oldValue.keys)
                let newLayers     = layers.subtracting(oldLayers)
                let removedLayers = oldLayers.subtracting(layers)
                
                removeReferences(for: removedLayers, in: oldValue)
                
                guard let colorScheme = containerViewController?.hierarchyInspectorColorScheme else {
                    return
                }
                
                addReferences(for: newLayers, with: colorScheme)
            }
        }
        
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
        
        var viewHierarchySnapshot: ViewHierarchySnapshot? {
            guard
                let cachedSnapshot = cachedViewHierarchySnapshot,
                Date() <= cachedSnapshot.expiryDate
            else {
                
                let start = Date()
                
                let snapshot = makeSnapshot()
                
                cachedViewHierarchySnapshot = snapshot
                
                print("[Hierarchy Inspector] \(String(describing: classForCoder)): calculated snapshot in \(Date().timeIntervalSince(start)) s")
                
                return snapshot
            }
            
            return cachedSnapshot
        }
        
        private var cachedViewHierarchySnapshot: ViewHierarchySnapshot?
        
        public var isShowingLayers: Bool {
            viewHierarchyReferences.keys.isEmpty == false
        }
        
        #warning("TODO: migrate Manager operations to OperationQueue")
        private(set) lazy var operationQueue = OperationQueue()
        
        deinit {
            invalidate()
        }
        
        func invalidate() {
            hostViewController = nil
            
            cachedViewHierarchySnapshot = nil
            
            viewHierarchyReferences.removeAll()
            
            wireframeViews.removeAll()
            
            inspectorViews.removeAll()
            
            operationQueue.cancelAllOperations()
        }
        
        struct Operation {
            let name: String
            let closure: Closure
        }
        
        func asyncOperation(name: String, execute closure: @escaping Closure) {
            async(operation: Operation(name: name, closure: closure), in: containerViewController?.view.window)
        }
        
    }
}

// MARK: - Layers Hierarchy

extension HierarchyInspector.Manager {
    
    var activeLayers: [HierarchyInspector.Layer] {
        viewHierarchyReferences.compactMap { dict -> HierarchyInspector.Layer? in
            guard dict.value.isEmpty == false else {
                return nil
            }
            
            return dict.key
        }
    }
    
    var availableLayers: [HierarchyInspector.Layer] {
        viewHierarchySnapshot?.availableLayers ?? []
    }
    
    var populatedLayers: [HierarchyInspector.Layer] {
        viewHierarchySnapshot?.populatedLayers ?? []
    }
    
    private func calculateAvailableLayers() -> [HierarchyInspector.Layer] {
        containerViewController?.hierarchyInspectorLayers.uniqueValues ?? [.allViews]
    }
}

// MARK: - ViewController Hierarchy

extension HierarchyInspector.Manager {
    var containerViewController: HierarchyInspectableProtocol? {
        hostViewController
//        containerViewControllerHierarchy.first
    }
    
//    var containerViewControllerHierarchy: [HierarchyInspectorPresentable] {
//        [
//            hostViewController?.splitViewController,
//            hostViewController?.tabBarController,
//            hostViewController?.navigationController,
//            hostViewController
//        ].compactMap { $0 as? HierarchyInspectorPresentable }
//    }
}

// MARK: - Private Helpers

private extension HierarchyInspector.Manager {
    
    func async(operation: Operation, in window: UIWindow?) {
        window?.showActivityIndicator(for: operation)
        
        DispatchQueue.main.async {
            
            operation.closure()
            
            window?.removeActivityIndicator()
        }
    }
    
    func makeSnapshot() -> ViewHierarchySnapshot? {
        guard let containerView = containerViewController?.view else {
            return nil
        }
        
        return ViewHierarchySnapshot(availableLayers: calculateAvailableLayers(), in: containerView)
    }
}

// MARK: - ViewReference

private extension HierarchyInspector.Manager {
    
    func updateLayerViews(to newValue: [ViewHierarchyReference : LayerView], from oldValue: [ViewHierarchyReference : LayerView]) {
        
        let viewReferences    = Set<ViewHierarchyReference>(newValue.keys)
        
        let oldViewReferences = Set<ViewHierarchyReference>(oldValue.keys)
        
        let removedReferences = oldViewReferences.subtracting(viewReferences)
        
        let newReferences     = viewReferences.subtracting(oldViewReferences)
        
        removedReferences.forEach {
            guard let layerView = oldValue[$0] else {
                return
            }
            
            layerView.removeFromSuperview()
        }
        
        newReferences.forEach {
            guard
                let referenceView = $0.view,
                let inspectorView = newValue[$0]
            else {
                return
            }
            
            referenceView.installView(inspectorView)
        }
    }
    
    func removeReferences(for removedLayers: Set<HierarchyInspector.Layer>, in oldValue: [HierarchyInspector.Layer: [ViewHierarchyReference]]) {
        
        var removedReferences = [ViewHierarchyReference]()
        
        removedLayers.forEach { layer in
            print("[Hierarchy Inspector] \(layer) was removed")
            
            oldValue[layer]?.forEach {
                
                print("[Hierarchy Inspector] \(layer): removing reference to \($0.elementName)")
                removedReferences.append($0)
            
            }
        }
        
        for (layer, references) in viewHierarchyReferences where layer != .wireframes {
            
            references.forEach { reference in
                
                if let index = removedReferences.firstIndex(of: reference) {
                    print("[Hierarchy Inspector] reference to \(reference.elementName) reclaimed by \(layer)")
                    
                    removedReferences.remove(at: index)
                    
                }
            }
        }
        
        removedReferences.forEach { (removedReference) in
            inspectorViews.removeValue(forKey: removedReference)
        }
        
        if removedLayers.contains(.wireframes) {
            wireframeViews.removeAll()
        }
    }
    
    func addReferences(for newLayers: Set<HierarchyInspector.Layer>, with colorScheme: ColorScheme) {
        for newLayer in newLayers {
            guard let references = viewHierarchyReferences[newLayer] else {
                continue
            }
            
            switch newLayer.showLabels {
            case true:
                references.forEach { viewReference in
                    guard
                        inspectorViews[viewReference] == nil,
                        let element = viewReference.view
                    else {
                        return
                    }
                    
                    let inspectorView = HighlightView(
                        frame: element.bounds,
                        name: element.className,
                        colorScheme: colorScheme,
                        reference: viewReference
                    )
                    
                    inspectorViews[viewReference] = inspectorView
                }
                
            case false:
                references.forEach { viewReference in
                    guard
                        inspectorViews[viewReference] == nil,
                        let element = viewReference.view
                    else {
                        return
                    }
                    
                    let wireframeView = WireframeView(
                        frame: element.bounds,
                        reference: viewReference
                    )
                    
                    wireframeViews[viewReference] = wireframeView
                }
            }
            
        }
    }
}
