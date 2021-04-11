//
//  Manager.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

extension HierarchyInspector {
    public final class Manager: Create {
        
        lazy var operationQueue: OperationQueue = OperationQueue.main
        
        var elementInspectorCoordinator: ElementInspectorCoordinator?
        
        var hierarchyInspectorCoordinator: HierarchyInspectorCoordinator?
        
        private(set) lazy var viewHierarchyLayersCoordinator = ViewHierarchyLayersCoordinator().then {
            $0.dataSource = self
            $0.delegate   = self
        }
        
        private(set) weak var hostViewController: HierarchyInspectableProtocol?
        
        var shouldCacheViewHierarchySnapshot = true
        
        private var cachedViewHierarchySnapshot: ViewHierarchySnapshot?
        
        // MARK: - Init
        
        public init(host: HierarchyInspectableProtocol) {
            self.hostViewController = host
        }
        
        deinit {
            invalidate()
        }
        
        func invalidate() {
            hostViewController = nil
            
            cachedViewHierarchySnapshot = nil
            
            viewHierarchyLayersCoordinator.invalidate()
            
            elementInspectorCoordinator = nil
            
            hierarchyInspectorCoordinator = nil
        }
        
        func present(animated: Bool) {
            guard let windowHierarchySnapshot = self.makeWindowHierarchySnapshot() else {
                return
            }
            
            let coordinator = HierarchyInspectorCoordinator(
                hierarchySnapshot: windowHierarchySnapshot,
                actionGroupsProvider: { [weak self] in self?.availableActions }
            ).then {
                $0.delegate = self
            }
            
            hostViewController?.present(coordinator.start(), animated: true)
            
            hierarchyInspectorCoordinator = coordinator
        }
    }
}

// MARK: - Actions

extension HierarchyInspector.Manager {
    
    var availableActions: ActionGroups {
        guard let viewHierarchySnapshot = self.viewHierarchySnapshot else {
            return []
        }
        
        // layer actions
        let layerActions = viewHierarchyLayersCoordinator.layerActions(for: viewHierarchySnapshot)
        
        // other actions
        let toggleAllLayersActions = viewHierarchyLayersCoordinator.toggleAllLayersActions(for: viewHierarchySnapshot)
        
        return [layerActions, toggleAllLayersActions]
    }
    
}

// MARK: - Snapshot

extension HierarchyInspector.Manager {
    
    var viewHierarchySnapshot: ViewHierarchySnapshot? {
        let start = Date()
        
        guard let hostViewController = hostViewController else {
            Console.print("could not caculate snapshot: host is nil")
            return nil
        }
        
        guard let cachedSnapshot = cachedViewHierarchySnapshot, Date() <= cachedSnapshot.expiryDate else {
            guard let snapshot = makeViewHierarchySnapshot() else {
                Console.print("\(hostViewController.classForCoder) could not caculate snapshot")
                return nil
            }
            
            if shouldCacheViewHierarchySnapshot {
                cachedViewHierarchySnapshot = snapshot
            }
            
            Console.print("📐 calculated snapshot in \(Date().timeIntervalSince(start)) s")
            
            return snapshot
        }
        
        Console.print("♻️ reused snapshot in \(Date().timeIntervalSince(start)) s")
        
        return cachedSnapshot
    }
    
    private var viewHierarchyLayers: [ViewHierarchyLayer] {
        var userLayers = hostViewController?.hierarchyInspectorLayers.uniqueValues ?? []
        
        return userLayers + [.allViews]
    }
    
    private func makeViewHierarchySnapshot() -> ViewHierarchySnapshot? {
        guard let hostView = hostViewController?.view else {
            return nil
        }
        
        let snapshot = ViewHierarchySnapshot(availableLayers: viewHierarchyLayers, in: hostView)
        
        return snapshot
    }
    
    private func makeWindowHierarchySnapshot() -> ViewHierarchySnapshot? {
        guard let hostWindow = hostViewController?.view.window else {
            return nil
        }
        
        let snapshot = ViewHierarchySnapshot(availableLayers: viewHierarchyLayers, in: hostWindow)
        
        return snapshot
    }
}

// MARK: - AsyncOperationProtocol

extension HierarchyInspector.Manager: AsyncOperationProtocol {
    
    func asyncOperation(name: String = #function, execute closure: @escaping Closure) {
        let asyncOperation = MainThreadAsyncOperation(name: name, closure: closure)
        
        operationQueue.addOperation(asyncOperation)
    }
}
