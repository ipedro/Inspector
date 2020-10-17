//
//  Manager.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

extension HierarchyInspector {
    public final class Manager: Create {
        private(set) var elementInspectorCoordinator: ElementInspectorCoordinator?
        
        private(set) lazy var viewHierarchyInspectorCoordinator = ViewHierarchyInspectorCoordinator().then {
            $0.dataSource = self
            $0.delegate   = self
        }
        
        private(set) weak var hostViewController: HierarchyInspectableProtocol?
        
        var shouldCacheViewHierarchySnapshot = true
        
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
            
            viewHierarchyInspectorCoordinator.invalidate()
        }
        
        var availableActions: [ActionGroup] {
            guard let viewHierarchySnapshot = self.viewHierarchySnapshot else {
                return []
            }
            
            // layer actions
            let layerActions = viewHierarchyInspectorCoordinator.layerActions(for: viewHierarchySnapshot)
            
            // other actions
            var otherActions = viewHierarchyInspectorCoordinator.otherActions(for: viewHierarchySnapshot)
            
            guard
                let topMostContainer = hostViewController?.topMostContainerViewController as? HierarchyInspectorPresentable,
                topMostContainer !== hostViewController
            else {
                return [layerActions, otherActions]
            }
            
            otherActions.actions.append(.inspect(vc: topMostContainer))
            
            return [layerActions, otherActions]
        }
        
    }
}

extension HierarchyInspector.Manager {
    
    func presentElementInspector(for reference: ViewHierarchyReference, from sourceView: UIView, animated: Bool) {
        guard let hostViewController = hostViewController else {
            return
        }
        
        let coordinator = ElementInspectorCoordinator(reference: reference).then {
            $0.delegate = self
        }
        
        elementInspectorCoordinator = coordinator
        
        let elementInspectorNavigationController = coordinator.start()
        elementInspectorNavigationController.popoverPresentationController?.sourceView = sourceView
        
        hostViewController.present(elementInspectorNavigationController, animated: animated)
    }

}

// MARK: - Private Helpers

private extension HierarchyInspector.Manager {
    func makeSnapshot() -> ViewHierarchySnapshot? {
        guard let hostView = hostViewController?.view else {
            return nil
        }
        
        let snapshot = ViewHierarchySnapshot(availableLayers: availableInspectorLayers, in: hostView)
        
        return snapshot
    }
}

// MARK: - ElementInspectorCoordinatorDelegate

extension HierarchyInspector.Manager: ElementInspectorCoordinatorDelegate {
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, showHighlightViewsVisibilityOf reference: ViewHierarchyReference) {
        viewHierarchyInspectorCoordinator.hideAllHighlightViews(false, containedIn: reference)
    }
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, hideHighlightViewsVisibilityOf reference: ViewHierarchyReference) {
        viewHierarchyInspectorCoordinator.hideAllHighlightViews(true, containedIn: reference)
    }
    
    func elementInspectorCoordinator(_ coordinator: ElementInspectorCoordinator, didFinishWith reference: ViewHierarchyReference) {
        viewHierarchyInspectorCoordinator.hideAllHighlightViews(false, containedIn: reference)
        
        elementInspectorCoordinator = nil
    }
}

// MARK: - ViewHierarchyLayerCoordinatorDataSource

extension HierarchyInspector.Manager: ViewHierarchyLayerCoordinatorDataSource {
    var colorScheme: ViewHierarchyColorScheme {
        hostViewController?.hierarchyInspectorColorScheme ?? .default
    }
    
    var availableInspectorLayers: [ViewHierarchyLayer] {
        hostViewController?.hierarchyInspectorLayers.uniqueValues ?? [.allViews]
    }
}

extension HierarchyInspector.Manager: ViewHierarchyLayerCoordinatorDelegate {
    func viewHierarchyLayerCoordinator(_ coordinator: ViewHierarchyInspectorCoordinator, didSelect viewHierarchyReference: ViewHierarchyReference, from highlightView: HighlightView) {
        presentElementInspector(for: viewHierarchyReference, from: highlightView.labelContentView, animated: true)
    }
}

// MARK: - HierarchyLayerManagerProtocol

extension HierarchyInspector.Manager: HierarchyLayerManagerProtocol {
    
    // MARK: - Install
    
    public func installLayer(_ layer: ViewHierarchyLayer) {
        viewHierarchyInspectorCoordinator.installLayer(layer)
    }

    public func installAllLayers() {
        viewHierarchyInspectorCoordinator.installAllLayers()
    }

    // MARK: - Remove

    public func removeAllLayers() {
        viewHierarchyInspectorCoordinator.removeAllLayers()
    }

    public func removeLayer(_ layer: ViewHierarchyLayer) {
        viewHierarchyInspectorCoordinator.removeLayer(layer)
    }
    
}
