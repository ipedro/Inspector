//  Copyright (c) 2021 Pedro Almeida
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

typealias Manager = Inspector.Manager

extension Inspector {
    public final class Manager: Create {
        
        // MARK: - Properties
        
        static let shared = Manager()
        
        weak var host: InspectableProtocol? {
            didSet {
                if oldValue != nil {
                    finish()
                }
                if host != nil {
                    start()
                }
            }
        }
        
        // MARK: - Properties
        
        private(set) lazy var operationQueue: OperationQueue = OperationQueue.main
        
        var elementInspectorCoordinator: ElementInspectorCoordinator? {
            didSet {
                asyncOperation {
                    oldValue?.finish()
                }
            }
        }
        
        var hierarchyInspectorCoordinator: HierarchyInspectorCoordinator? {
            didSet {
                asyncOperation {
                    oldValue?.finish()
                }
            }
        }
        
        var viewHierarchyLayersCoordinator: ViewHierarchyLayersCoordinator? {
            didSet {
                asyncOperation {
                    oldValue?.finish()
                }
            }
        }
        
        var shouldCacheViewHierarchySnapshot = true
        
        private var cachedSnapshots: [UIView: ViewHierarchySnapshot] = [:]
        
        // MARK: - Init
        
        private init() {}
        
        deinit {
            operationQueue.cancelAllOperations()
            host = nil
        }
        
        public func restart() {
            finish()
            start()
        }
        
        func start() {
            asyncOperation { [weak self] in
                guard let self = self else {
                    return
                }
                
                let coordinator = ViewHierarchyLayersCoordinator()
                coordinator.dataSource = self
                coordinator.delegate   = self
                
                self.viewHierarchyLayersCoordinator = coordinator
            }
        }
        
        func finish() {
            operationQueue.cancelAllOperations()
            
            asyncOperation { [weak self] in
                guard let self = self else { return }
                
                self.cachedSnapshots.removeAll()
                self.viewHierarchyLayersCoordinator = nil
                self.elementInspectorCoordinator = nil
                self.hierarchyInspectorCoordinator = nil
            }
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

extension Manager {
    
    var availableActionGroups: ActionGroups {
        guard
            let snapshot = viewHierarchySnapshot,
            let host = host,
            let viewHierarchyLayersCoordinator = viewHierarchyLayersCoordinator
        else {
            return []
        }
        
        let layerActions = viewHierarchyLayersCoordinator.availableLayerActions(for: snapshot)
        let toggleAllLayersActions = viewHierarchyLayersCoordinator.toggleAllLayersActions(for: snapshot)
        
        var actionGroups = host.inspectorActionGroups
        actionGroups.append(layerActions)
        actionGroups.append(toggleAllLayersActions)
        
        return actionGroups
    }
    
}

// MARK: - Host ViewController

extension Manager {
    
    var hostViewController: UIViewController? {
        viewHierarchyWindow?.rootViewController?.presentedViewController ?? viewHierarchyWindow?.rootViewController
    }
    
}

// MARK: - Snapshot

extension Manager {
    
    var viewHierarchySnapshot: ViewHierarchySnapshot? {
        snapshot(of: viewHierarchyWindow)
    }
    
    private func snapshot(of referenceView: UIView?) -> ViewHierarchySnapshot? {
        guard
            let referenceView = referenceView,
            let host = host
        else {
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

extension Manager: AsyncOperationProtocol {
    
    func asyncOperation(name: String = #function, execute closure: @escaping Closure) {
        let asyncOperation = MainThreadAsyncOperation(name: name, closure: closure)
        
        operationQueue.addOperation(asyncOperation)
    }
    
}

// MARK: - InspectableProtocol Extension

private extension InspectableProtocol {
    
    var availableLayers: [ViewHierarchyLayer] {
        var layers = inspectorViewHierarchyLayers
        layers.append(.systemViews)
        layers.append(.systemContainers)
        layers.append(.allViews)
        
        return layers.uniqueValues
    }
    
    var availableElementLibraries: [InspectorElementLibraryProtocol] {
        var elements = [InspectorElementLibraryProtocol]()
        elements.append(contentsOf: inspectorElementLibraries)
        elements.append(contentsOf: UIKitElementLibrary.standard)
        
        return elements
    }
    
}
