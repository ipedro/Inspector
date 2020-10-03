//
//  HierarchyInspector.Manager.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

extension HierarchyInspector {
    public final class Manager: NSObject {
        
        public init(host: HierarchyInspectableProtocol) {
            hostViewController = host
        }
        
        weak private(set) var hostViewController: HierarchyInspectableProtocol?
        
        var inspectorViewsForLayers: [HierarchyInspector.Layer: [HierarchyInspectorView]] = [:] {
            didSet {
                for (oldLayer, oldViews) in oldValue where inspectorViewsForLayers.keys.contains(oldLayer) == false {
                    oldViews.forEach { $0.removeFromSuperview() }
                }
            }
        }
        
        var viewHierarchySpapshot: HierarchyInspector.ViewHierarchySnapshot?
        
        public var isShowingLayers: Bool {
            inspectorViewsForLayers.keys.isEmpty == false
        }
        
        private(set) lazy var operationQueue = OperationQueue()
        
        deinit {
            invalidate()
        }
        
        func invalidate() {
            inspectorViewsForLayers.removeAll()
            
            hostViewController = nil
            
            operationQueue.cancelAllOperations()
        }
        
        struct Operation {
            let name: String
            let closure: Closure
        }
        
        #warning("TODO: migrate to Foundation OperationQueue")
        func async(operation name: String, execute closure: @escaping Closure) {
            async(operation: Operation(name: name, closure: closure), in: hostViewController?.view.window)
        }
        
        private func async(operation: Operation, in window: UIWindow?) {
            window?.showActivityIndicator(for: operation)
            
            DispatchQueue.main.async {
                operation.closure()
                
                window?.removeActivityIndicator()
            }
        }
    }
}

extension HierarchyInspector.Manager {
    
    var availableLayers: [HierarchyInspector.Layer] {
        var array = hostViewController?.hierarchyInspectorLayers ?? [.allViews]
        
        array.append(.wireframes)
        
        #if DEBUG
        array.append(.internalViews)
        #endif
        
        return array
    }
    
    var viewControllerHierarchy: [HierarchyInspectorPresentable] {
        [
            hostViewController?.splitViewController,
            hostViewController?.tabBarController,
            hostViewController?.navigationController,
            hostViewController
        ].compactMap { $0 as? HierarchyInspectorPresentable }
    }
    
    var inspectableViewHierarchy: [HierarchyInspectableView] {
        viewControllerHierarchy.first?.view.inspectableViewHierarchy ?? []
    }
    
    var activeLayersCount: Int {
        let activeLayers = inspectorViewsForLayers.filter { dict -> Bool in
            dict.value.isEmpty == false
        }
        
        return activeLayers.count
    }
    
    var populatedLayers: [HierarchyInspector.Layer] {
        guard
            let hierarchyInspectorSnapshot = viewHierarchySpapshot,
            Date() <= hierarchyInspectorSnapshot.expiryDate
        else {
            print("[Hierarchy Inspector] \(String(describing: classForCoder)): fresh calculation")
            
            let snapshot = HierarchyInspector.ViewHierarchySnapshot(
                populatedHirerchyLayers: availableLayers.filter {
                    $0.filter(viewHierarchy: inspectableViewHierarchy).isEmpty == false
                }
            )
            
            self.viewHierarchySpapshot = snapshot
            
            return snapshot.populatedHirerchyLayers
        }
        
        return hierarchyInspectorSnapshot.populatedHirerchyLayers
    }
    
}

// MARK: - Actions

extension HierarchyInspector.Manager {
    
    enum Action {
        
        case command(_ title: String, closure: Closure?)
    }
    
    var availableActions: [Action] {
        var array = [Action]()
        
        let populatedLayers = self.populatedLayers
        
        let availableLayers = self.availableLayers
        
        availableLayers.forEach { layer in
            var action: Action {
                guard populatedLayers.contains(layer) else {
                    return .command(layer.emptyText, closure: nil)
                }
                
                switch isShowingLayer(layer) {
                case true:
                    return .command(layer.selectedAlertAction) { [weak self] in
                        self?.removeLayer(layer)
                    }
                    
                case false:
                    return .command(layer.unselectedKeyCommand) { [weak self] in
                        self?.installLayer(layer)
                    }
                }
            }
            
            array.append(action)
        }
        
        if activeLayersCount > .zero {
            array.append(
                .command(Texts.hideAllLayers) { [weak self] in
                    self?.removeAllLayers()
                }
            )
        }
        
        if activeLayersCount < populatedLayers.count {
            array.append(
                .command(Texts.showAllLayers) { [weak self] in
                    self?.installAllLayers()
                }
            )
        }
        
        return array
    }
}

extension HierarchyInspector.Manager.Action {
    var alertAction: UIAlertAction? {
        switch self {
        case let .command(title, closure):
            let action = UIAlertAction(title: title, style: .default) { _ in
                if let closure = closure {
                    closure()
                }
            }
            
            action.isEnabled = closure != nil
            
            return action
        }
    }
    
}
