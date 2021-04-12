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
        
        private var cachedSnapshots: [UIView: ViewHierarchySnapshot] = [:]
        
        // MARK: - Init
        
        public init(host: HierarchyInspectableProtocol) {
            self.hostViewController = host
        }
        
        deinit {
            invalidate()
        }
        
        func invalidate() {
            hostViewController = nil
            
            cachedSnapshots.removeAll()
            
            viewHierarchyLayersCoordinator.invalidate()
            
            elementInspectorCoordinator = nil
            
            hierarchyInspectorCoordinator = nil
        }
        
        func present(animated: Bool) {
            guard
                hierarchyInspectorCoordinator == nil,
                let windowHierarchySnapshot = snapshot(of: hostViewController?.view.window)
            else {
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
        guard let snapshot = viewHierarchySnapshot else {
            return []
        }
        
        var actions = ActionGroups()
        // layer actions
        actions.append(viewHierarchyLayersCoordinator.layerActions(for: snapshot))
        // toggle all
        actions.append(viewHierarchyLayersCoordinator.toggleAllLayersActions(for: snapshot))
        
        return actions
    }
    
}

// MARK: - ViewHierarchySnapshotableProtocol

protocol ViewHierarchySnapshotableProtocol {
    
    var viewHierarchySnapshot: ViewHierarchySnapshot? { get }
    
    var shouldCacheViewHierarchySnapshot: Bool { get }
}

extension HierarchyInspector.Manager {
    
    var viewHierarchySnapshot: ViewHierarchySnapshot? {
        snapshot(of: hostViewController?.view)
    }
    
    private func snapshot(of view: UIView?) -> ViewHierarchySnapshot? {
        guard let view = view else {
            return nil
        }
        
        guard
            shouldCacheViewHierarchySnapshot,
            let cachedSnapshot = cachedSnapshots[view],
            Date() <= cachedSnapshot.expiryDate
        else {
            let layers = hostViewController?.allAvailableLayers ?? []
            let attributeInspectorSections = hostViewController?.allAvailableAttributeInspectorSections ?? []
            let snapshot = ViewHierarchySnapshot(
                availableLayers: layers,
                availableAttributeInspectorSections: attributeInspectorSections,
                in: view
            )
            
            cachedSnapshots[view] = snapshot
            
            return snapshot
        }
        
        return cachedSnapshot
    }
    
}

// MARK: - AsyncOperationProtocol

extension HierarchyInspector.Manager: AsyncOperationProtocol {
    
    func asyncOperation(name: String = #function, execute closure: @escaping Closure) {
        let asyncOperation = MainThreadAsyncOperation(name: name, closure: closure)
        
        operationQueue.addOperation(asyncOperation)
    }
}
