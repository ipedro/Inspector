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

extension HierarchyInspector {
    public final class Manager: Create {
        
        // MARK: - Public Properties
        
        public static let shared = Manager()
        
        var host: HierarchyInspectableProtocol?
        
        // MARK: - Properties
        
        lazy var operationQueue: OperationQueue = OperationQueue.main
        
        var elementInspectorCoordinator: ElementInspectorCoordinator?
        
        var hierarchyInspectorCoordinator: HierarchyInspectorCoordinator?
        
        lazy var viewHierarchyLayersCoordinator = ViewHierarchyLayersCoordinator().then {
            $0.dataSource = self
            $0.delegate   = self
        }
        
        var shouldCacheViewHierarchySnapshot = true
        
        private var cachedSnapshots: [UIView: ViewHierarchySnapshot] = [:]
        
        // MARK: - Init
        
        private init() {}
        
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
        viewHierarchyWindow?.rootViewController?.presentedViewController ?? viewHierarchyWindow?.rootViewController
    }
    
}

// MARK: - Snapshot

extension HierarchyInspector.Manager {
    
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
        layers.append(.systemContainers)
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
