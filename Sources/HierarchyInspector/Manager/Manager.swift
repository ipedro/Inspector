//
//  Manager.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

extension HierarchyInspector {
    public final class Manager: Create {
        
        var elementInspectorCoordinator: ElementInspectorCoordinator?
        
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
        }
    }
}

// MARK: - Actions

extension HierarchyInspector.Manager {
    
    var availableActions: [ActionGroup] {
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
            guard let snapshot = makeSnapshot() else {
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
        hostViewController?.hierarchyInspectorLayers.uniqueValues ?? [.allViews]
    }
    
    private func makeSnapshot() -> ViewHierarchySnapshot? {
        guard let hostView = hostViewController?.view else {
            return nil
        }
        
        let snapshot = ViewHierarchySnapshot(availableLayers: viewHierarchyLayers, in: hostView)
        
        return snapshot
    }
}
