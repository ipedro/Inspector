//
//  HierarchyInspectableProtocol+ActionSheetPresentation.swift
//  
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectorPresentable: HierarchyInspectableProtocol {
    
    func presentHierarchyInspector(animated: Bool)
    
}

public extension HierarchyInspectorPresentable {
    
    func presentHierarchyInspector(animated: Bool) {
        presentHierarchyInspector(animated: animated, inspecting: false)
    }
    
}

// MARK: - ActionSheet Presentation

extension HierarchyInspectorPresentable {
    var canPresentHierarchyInspector: Bool {
        #if DEBUG
        return presentingViewController is UIAlertController == false
        #else
        return self is UIAlertController
        #endif
    }
    
    func presentHierarchyInspector(animated: Bool, inspecting: Bool) {
        guard canPresentHierarchyInspector else {
            return
        }
        
        let start = Date()
        
        performAsyncOperation {
            let alertController = self.makeAlertController(for: self.view, inspectingSelf: inspecting)
            
            self.present(alertController, animated: true) {
                let elaspedTime = Date().timeIntervalSince(start)
                
                print("Presented Hierarchy Inspector in \(elaspedTime) seconds")
            }
        }
    }
    
    // TODO: break up method. create structures or fabricator
    private func makeAlertController(for view: UIView, inspectingSelf: Bool = false) -> UIAlertController {
        let inspectableViewHierarchy = view.inspectableViewHierarchy
        
        let alertController = UIAlertController(
            title: Texts.hierarchyInspector,
            message: "\(inspectableViewHierarchy.count) inspectable views in \(view.className)",
            preferredStyle: .alert
        ).then {
            if #available(iOS 13.0, *) {
                $0.view.tintColor = .label
            } else {
                $0.view.tintColor = .darkText
            }
        }
        
        let removeHierarchyViewsIfNeeded: (UIAlertAction) -> Void = { _ in
            if self is UIAlertController {
                return
            }
            
            alertController.hierarchyInspectorViews.removeAll()
        }
        
        alertController.addAction(
            UIAlertAction(title: Texts.closeInspector, style: .cancel, handler: removeHierarchyViewsIfNeeded)
        )
        
        func toggleLayerAction(for layer: HierarchyInspector.Layer) -> UIAlertAction {
            let layerIsPresenting = hierarchyInspectorViews[layer]?.isEmpty == false
            
            let filteredViewHierarchy = layer.filter(viewHierarchy: inspectableViewHierarchy)
            
            switch (layerIsPresenting, filteredViewHierarchy.isEmpty) {
            case (true, _):
                return UIAlertAction(title: layer.selectedAlertAction, style: .default) { [weak self] action in
                    removeHierarchyViewsIfNeeded(action)
                    
                    self?.removeLayer(layer)
                }
                
            case (false, true):
                let alert = UIAlertAction(title: layer.emptyText, style: .default, handler: nil)
                alert.isEnabled = false
                
                return alert
                
            case (false, false):
                return UIAlertAction(title: layer.unselectedAlertAction, style: .default) { [weak self] action in
                    removeHierarchyViewsIfNeeded(action)
                    
                    self?.create(layer: layer, filteredViewHierarchy: filteredViewHierarchy)
                }
            }
        }
        
        let availableLayers: [HierarchyInspector.Layer] = {
            var array = hierarchyInspectorLayers.isEmpty ? [.allViews] : hierarchyInspectorLayers
            
            array.append(.wireframes)
            
            #if DEBUG
            array.append(.internalViews)
            #endif
            
            return array
        }()
        
        alertController.addAction(.separator(availableLayers.isEmpty ? "No Layers" : "\(availableLayers.count) Layers"))
        
        availableLayers.forEach { layer in
            alertController.addAction(toggleLayerAction(for: layer))
        }
        
        let actions: [UIAlertAction] = {
            var actions = [UIAlertAction]()
            
            if hierarchyInspectorViews.keys.isEmpty == false {
                actions.append(
                    UIAlertAction(title: Texts.hideAllLayers, style: .default) { [weak self] action in
                        removeHierarchyViewsIfNeeded(action)
                        
                        self?.removeAllLayers()
                    }
                )
            }
            
            if hierarchyInspectorLayers.isEmpty == false, hierarchyInspectorViews.keys.count < populatedHierarchyInspectorLayers.count {
                actions.append(
                    UIAlertAction(title: Texts.showAllLayers, style: .default) { [weak self] action in
                        removeHierarchyViewsIfNeeded(action)
                        
                        self?.installAllLayers(in: inspectableViewHierarchy)
                    }
                )
            }
            
            #if DEBUG
            let navigationControllers = [tabBarController, navigationController, splitViewController]
            
            for controller in navigationControllers {
                if let controller = controller as? HierarchyInspectorPresentable {
                    actions.append(
                        UIAlertAction(
                            title: Texts.inspect(String(describing: controller.classForCoder)),
                            style: .default
                        ) { action in
                            removeHierarchyViewsIfNeeded(action)
                            
                            controller.presentHierarchyInspector(animated: true)
                        }
                    )
                }
            }
            
            if self is UIAlertController == false {
                actions.append(
                    UIAlertAction(
                        title: inspectingSelf ? Texts.stopInspecting : Texts.inspect("Hierarchy Inspector"),
                        style: .default
                    ) { [weak self] action in
                        removeHierarchyViewsIfNeeded(action)
                        
                        self?.presentHierarchyInspector(animated: true, inspecting: !inspectingSelf)
                    }
                )
            }
            #endif
            
            return actions
        }()
        
        if actions.isEmpty == false {
            alertController.addAction(.separator("Actions"))
            
            actions.forEach { alertController.addAction($0) }
        }
        
        if inspectingSelf {
            UIAlertController.sharedHierarchyInspectorViews.removeAll()
            
            alertController.installAllLayers(in: alertController.view.inspectableViewHierarchy)
        }
        
        return alertController
    }
}
