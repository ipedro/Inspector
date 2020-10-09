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
        
        @available(*, deprecated, message: "temporary holding coordinator. remove")
        var elementInspectorCoordinator: ElementInspectorCoordinator?
        
        var shouldCacheViewHierarchySnapshot = true
        
        private(set) weak var hostViewController: HierarchyInspectableProtocol?
        
        var viewHierarchyReferences: [ViewHierarchyLayer: [ViewHierarchyReference]] = [:] {
            didSet {
                let layers = Set<ViewHierarchyLayer>(viewHierarchyReferences.keys)
                let oldLayers = Set<ViewHierarchyLayer>(oldValue.keys)
                let newLayers = layers.subtracting(oldLayers)
                let removedLayers = oldLayers.subtracting(layers)
                
                removeReferences(for: removedLayers, in: oldValue)
                
                guard let colorScheme = hostViewController?.hierarchyInspectorColorScheme else {
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
            let start = Date()
            
            guard let hostViewController = hostViewController else {
                print("\(Date()) [Hierarchy Inspector] could not caculate snapshot: host is nil")
                
                return nil
            }
            
            guard let cachedSnapshot = cachedViewHierarchySnapshot, Date() <= cachedSnapshot.expiryDate else {
                guard let snapshot = makeSnapshot() else {
                    print("\(Date()) [Hierarchy Inspector] \(hostViewController.view.className): could not caculate snapshot")
                    
                    return nil
                }
                
                if shouldCacheViewHierarchySnapshot {
                    cachedViewHierarchySnapshot = snapshot
                }
                
                print("\(Date()) [Hierarchy Inspector] \(snapshot.viewHierarchy.className): 📐 calculated snapshot in \(Date().timeIntervalSince(start)) s")
                
                return snapshot
            }
            
            print("\(Date()) [Hierarchy Inspector] \(cachedSnapshot.viewHierarchy.className): ♻️ reused snapshot in \(Date().timeIntervalSince(start)) s")
            
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
        
        struct Operation: Equatable {
            let identifier = UUID()
            
            let name: String
            
            let closure: Closure
            
            static func == (lhs: HierarchyInspector.Manager.Operation, rhs: HierarchyInspector.Manager.Operation) -> Bool {
                lhs.identifier == rhs.identifier
            }
        }
        
        func asyncOperation(name: String, execute closure: @escaping Closure) {
            async(operation: Operation(name: name, closure: closure), in: hostViewController?.view.window)
        }
    }
}

// MARK: - Layers Hierarchy

extension HierarchyInspector.Manager {
    var activeLayers: [ViewHierarchyLayer] {
        viewHierarchyReferences.compactMap { dict -> ViewHierarchyLayer? in
            guard dict.value.isEmpty == false else {
                return nil
            }
            
            return dict.key
        }
    }
    
    var availableLayers: [ViewHierarchyLayer] {
        viewHierarchySnapshot?.availableLayers ?? []
    }
    
    var populatedLayers: [ViewHierarchyLayer] {
        viewHierarchySnapshot?.populatedLayers ?? []
    }
    
    private func calculateAvailableLayers() -> [ViewHierarchyLayer] {
        hostViewController?.hierarchyInspectorLayers.uniqueValues ?? [.allViews]
    }
}

// MARK: - Private Helpers

private extension HierarchyInspector.Manager {
    func async(operation: Operation, in window: UIWindow?) {
        window?.showActivityIndicator(for: operation)
        
        DispatchQueue.main.async {
            operation.closure()
            
            window?.removeActivityIndicator(for: operation)
        }
    }
    
    func makeSnapshot() -> ViewHierarchySnapshot? {
        guard let hostView = hostViewController?.view else {
            return nil
        }
        
        return ViewHierarchySnapshot(availableLayers: calculateAvailableLayers(), in: hostView)
    }
}

// MARK: - ViewReference

private extension HierarchyInspector.Manager {
    func updateLayerViews(to newValue: [ViewHierarchyReference: LayerView], from oldValue: [ViewHierarchyReference: LayerView]) {
        let viewReferences = Set<ViewHierarchyReference>(newValue.keys)
        
        let oldViewReferences = Set<ViewHierarchyReference>(oldValue.keys)
        
        let removedReferences = oldViewReferences.subtracting(viewReferences)
        
        let newReferences = viewReferences.subtracting(oldViewReferences)
        
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
            
            referenceView.installView(inspectorView, .autoResizingMask)
        }
    }
    
    func removeReferences(for removedLayers: Set<ViewHierarchyLayer>, in oldValue: [ViewHierarchyLayer: [ViewHierarchyReference]]) {
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
        
        removedReferences.forEach { removedReference in
            inspectorViews.removeValue(forKey: removedReference)
        }
        
        if removedLayers.contains(.wireframes) {
            wireframeViews.removeAll()
        }
    }
    
    func addReferences(for newLayers: Set<ViewHierarchyLayer>, with colorScheme: ColorScheme) {
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
                    ).then {
                        $0.delegate = self
                    }
                    
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

// MARK: - HighlightViewDelegate

extension HierarchyInspector.Manager: HighlightViewDelegate {
    func highlightView(didTap view: UIView, with reference: ViewHierarchyReference) {
        guard let hostViewController = hostViewController else {
            return
        }
        
        let coordinator = ElementInspectorCoordinator(reference: reference, sourceView: view)
        
        elementInspectorCoordinator = coordinator
        
        hostViewController.present(coordinator.start(), animated: true)
    }
}
