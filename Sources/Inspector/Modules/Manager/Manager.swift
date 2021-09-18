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

    enum InspectorError: Error {
        case noViewHierarchySnapshot
    }

    public final class Manager: Create {


        // MARK: - Properties
        
        static let shared = Manager()
        
        weak var host: InspectorHostable? {
            didSet {
                if oldValue != nil {
                    finish()
                }
                if host != nil {
                    start()
                }
            }
        }

        var swiftUIhost: InspectorSwiftUIHostable? {
            didSet {
                host = swiftUIhost
            }
        }
        
        // MARK: - Properties
        
        private(set) lazy var operationQueue = OperationQueue.main
        
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
        
        func restart() {
            finish()
            start()
        }
        
        func start() {
            let coordinator = ViewHierarchyLayersCoordinator()
            coordinator.dataSource = self
            coordinator.delegate = self

            self.viewHierarchyLayersCoordinator = coordinator
        }
        
        func finish() {
            viewHierarchyLayersCoordinator = nil
            elementInspectorCoordinator = nil
            hierarchyInspectorCoordinator = nil

            cachedSnapshots.removeAll()
            operationQueue.cancelAllOperations()
        }

        public func present(animated: Bool = true) {
            guard let coordinator = makeHierarchyInspectorCoordinator() else { return }

            let inspectorViewController = coordinator.start()

            hostViewController?.present(inspectorViewController, animated: animated)
        }

        func makeHierarchyInspectorCoordinator() -> HierarchyInspectorCoordinator? {
            guard let viewHierarchySnapshot = viewHierarchySnapshot else { return nil }

            let coordinator = HierarchyInspectorCoordinator(
                hierarchySnapshot: viewHierarchySnapshot,
                commandGroupsProvider: { [weak self] in self?.availableCommandGroups }
            ).then {
                $0.delegate = self
            }

            hierarchyInspectorCoordinator = coordinator

            return coordinator
        }
    }
}

// MARK: - Commands

extension Manager {
    var availableCommandGroups: CommandGroups {
        guard
            let snapshot = viewHierarchySnapshot,
            let host = host,
            let viewHierarchyLayersCoordinator = viewHierarchyLayersCoordinator
        else {
            return []
        }
        
        let layerCommands = viewHierarchyLayersCoordinator.availableLayerCommands(for: snapshot)
        let toggleAllLayersCommands = viewHierarchyLayersCoordinator.toggleAllLayersCommands(for: snapshot)
        
        var commandGroups = host.inspectorCommandGroups ?? []
        commandGroups.append(toggleAllLayersCommands)
        commandGroups.append(layerCommands)
        
        return commandGroups
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
        guard let window = viewHierarchyWindow else { return nil }
        return snapshot(of: window)
    }
    
    private func snapshot(of referenceView: UIView) -> ViewHierarchySnapshot {
        guard
            shouldCacheViewHierarchySnapshot,
            let cachedSnapshot = cachedSnapshots[referenceView],
            Date() <= cachedSnapshot.expiryDate
        else {
            let snapshot = ViewHierarchySnapshot(
                availableLayers: host?.availableLayers ?? [],
                elementLibraries: host?.availableElementLibraries ?? [],
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

// MARK: - InspectorHostable Extension

private extension InspectorHostable {
    var availableLayers: [ViewHierarchyLayer] {
        var layers = inspectorViewHierarchyLayers ?? []
        layers.append(.allViews)
        layers.append(.systemViews)
        layers.append(.systemContainers)
        
        return layers.uniqueValues()
    }
    
    var availableElementLibraries: [InspectorElementLibraryProtocol] {
        var elements = [InspectorElementLibraryProtocol]()
        
        if let inspectorElementLibraries = inspectorElementLibraries {
            elements.append(contentsOf: inspectorElementLibraries)
        }
        
        elements.append(contentsOf: UIKitElementLibrary.allCases)
        
        return elements
    }
}
