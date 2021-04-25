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
        
        lazy var viewHierarchyLayersCoordinator = ViewHierarchyLayersCoordinator().then {
            $0.dataSource = self
            $0.delegate   = self
        }
        
        let host: HierarchyInspectableProtocol
        
        var shouldCacheViewHierarchySnapshot = true
        
        private var cachedSnapshots: [UIView: ViewHierarchySnapshot] = [:]
        
        // MARK: - Init
        
        public init(host: HierarchyInspectableProtocol) {
            self.host = host
            host.window?.hierarchyInspectorManager = self
        }
        
        deinit {
            invalidate()
        }
        
        func invalidate() {
            operationQueue.isSuspended = true
            
            cachedSnapshots.removeAll()
            
            viewHierarchyLayersCoordinator.invalidate()
            
            elementInspectorCoordinator = nil
            
            hierarchyInspectorCoordinator = nil
        }
        
        public func present(animated: Bool) {
            guard
                hierarchyInspectorCoordinator == nil,
                let viewHierarchySnapshot = viewHierarchySnapshot
            else {
                return
            }
            
            let coordinator = HierarchyInspectorCoordinator(
                hierarchySnapshot: viewHierarchySnapshot,
                actionGroupsProvider: { [weak self] in self?.availableActionGroups }
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
    
    var availableActionGroups: ActionGroups {
        guard let snapshot = viewHierarchySnapshot else {
            return []
        }
        
        var actionGroups = ActionGroups()
        // layer actions
        actionGroups.append(viewHierarchyLayersCoordinator.layerActions(for: snapshot))
        // toggle all
        actionGroups.append(viewHierarchyLayersCoordinator.toggleAllLayersActions(for: snapshot))
        
        return actionGroups
    }
    
}

// MARK: - Host ViewController

extension HierarchyInspector.Manager {
    
    var hostViewController: UIViewController? {
        host.window?.rootViewController?.presentedViewController ?? host.window?.rootViewController
    }
    
}

// MARK: - Snapshot

extension HierarchyInspector.Manager {
    
    var viewHierarchySnapshot: ViewHierarchySnapshot? {
        snapshot(of: host.window)
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
            let snapshot = ViewHierarchySnapshot(
                availableLayers: host.availableLayers,
                elementLibraries: host.availableElementLibraries,
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

// MARK: - HierarchyInspectableProtocol Extension

private extension HierarchyInspectableProtocol {
    
    var availableLayers: [ViewHierarchyLayer] {
        var layers = hierarchyInspectorLayers
        layers.append(.internalViews)
        layers.append(.allViews)
        
        return layers.uniqueValues
    }
    
    var availableElementLibraries: [HierarchyInspectorElementLibraryProtocol] {
        var elements = [HierarchyInspectorElementLibraryProtocol]()
        elements.append(contentsOf: hierarchyInspectorElementLibraries)
        elements.append(contentsOf: UIKitElementLibrary.standard)
        
        return elements
    }
    
}
