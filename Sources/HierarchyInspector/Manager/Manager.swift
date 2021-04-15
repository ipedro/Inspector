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
        
        private(set) weak var hostViewController: HierarchyInspectableViewControllerProtocol?
        
        var shouldCacheViewHierarchySnapshot = true
        
        private var cachedSnapshots: [UIView: ViewHierarchySnapshot] = [:]
        
        // MARK: - Init
        
        public init(host: HierarchyInspectableViewControllerProtocol) {
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
                let windowHierarchySnapshot = windowHierarchySnapshot
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
    
    var windowHierarchySnapshot: ViewHierarchySnapshot? {
        snapshot(of: hostViewController?.view.window)
    }
    
    private func snapshot(of referenceView: UIView?) -> ViewHierarchySnapshot? {
        guard let referenceView = referenceView else {
            return nil
        }
        
        guard
            shouldCacheViewHierarchySnapshot,
            let cachedSnapshot = cachedSnapshots[referenceView],
            Date() <= cachedSnapshot.expiryDate
        else {
            let availableLayers = hostViewController?.availableLayers ?? []
            
            let availableElementLibraries = hostViewController?.availableElementLibraries ?? []
            
            let snapshot = ViewHierarchySnapshot(
                availableLayers: availableLayers,
                elementLibraries: availableElementLibraries,
                in: referenceView
            )
            
            cachedSnapshots[referenceView] = snapshot
            
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
