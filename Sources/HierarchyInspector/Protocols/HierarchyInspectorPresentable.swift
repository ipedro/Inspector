//
//  HierarchyInspectableProtocol+ActionSheetPresentation.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectorPresentable: HierarchyInspectableProtocol {
    var canPresentHierarchyInspector: Bool { get }
    
    func presentHierarchyInspector(animated: Bool)
    
}

public extension HierarchyInspectorPresentable {
    
    func presentHierarchyInspector(animated: Bool) {
        presentHierarchyInspector(animated: animated, inspecting: false)
    }
    
}

// MARK: - ActionSheet Presentation

extension HierarchyInspectorPresentable {
    public var canPresentHierarchyInspector: Bool {
        presentingViewController is UIAlertController == false
    }
    
    func presentHierarchyInspector(animated: Bool, inspecting: Bool) {
        guard canPresentHierarchyInspector else {
            return
        }
        
        guard let topViewController = hierarchyInspectorManager.viewControllerHierarchy.first else {
            return
        }
        
        let start = Date()
        
        hierarchyInspectorManager.async(operation: "Calculating hierarchy") {
            guard let alertController = self.makeAlertController(for: topViewController.hierarchyInspectorManager, in: topViewController, inspecting: inspecting) else {
                return
            }
            
            topViewController.present(alertController, animated: true) {
                let elaspedTime = Date().timeIntervalSince(start)
                
                print("Presented Hierarchy Inspector in \(elaspedTime) seconds")
            }
        }
    }
    
    // TODO: break up method. create structures or fabricator
    private func makeAlertController(for manager: HierarchyInspector.Manager, in hostViewController: HierarchyInspectableProtocol, inspecting: Bool) -> UIAlertController? {
        guard let hostViewController = manager.hostViewController else {
            return nil
        }
        
        let alertController = UIAlertController(
            title: Texts.hierarchyInspector,
            message: "\(manager.inspectableViewHierarchy.count) inspectable views in \(hostViewController.view.className)",
            preferredStyle: .alert
        ).then {
            if #available(iOS 13.0, *) {
                $0.view.tintColor = .label
            } else {
                $0.view.tintColor = .darkText
            }
        }
        
        // Close button
        alertController.addAction(
            UIAlertAction(title: Texts.closeInspector, style: .cancel, handler: nil)
        )
        
        // Layers count
        let availableLayersCount = manager.availableLayers.count
        alertController.addAction(.separator(availableLayersCount == .zero ? "No Layers" : "\(availableLayersCount) Layers"))
        
        // Manager actions
        let managerActions = manager.availableActions.compactMap { $0.alertAction }
        managerActions.forEach { alertController.addAction($0) }
        
        // Alert controller inspection
        if inspecting {
            alertController.hierarchyInspectorManager.installAllLayers()
        }
        
        return alertController
    }
    
}
