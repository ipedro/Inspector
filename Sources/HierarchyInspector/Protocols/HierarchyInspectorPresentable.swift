//
//  HierarchyInspectableProtocol+ActionSheetPresentation.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectorPresentable: HierarchyInspectableProtocol {
    
    var hierarchyInspectorManager: HierarchyInspector.Manager { get }
    
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
        
        let start = Date()
        
        hierarchyInspectorManager.async(operation: "Calculating hierarchy") { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let alertController = self.makeAlertController(for: self.hierarchyInspectorManager, inspecting: inspecting) else {
                return
            }
            
            self.present(alertController, animated: true) {
                let elaspedTime = Date().timeIntervalSince(start)
                
                print("Presented Hierarchy Inspector in \(elaspedTime) seconds")
            }
        }
    }
    
    // TODO: break up method. create structures or fabricator
    private func makeAlertController(for manager: HierarchyInspector.Manager, inspecting: Bool) -> UIAlertController? {
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
        
        // Manager actions
        manager.availableActions.forEach { group in
            group.alertActions.forEach { alertController.addAction($0) }
        }
        
        // Alert controller inspection
        if inspecting {
            alertController.hierarchyInspectorManager.installAllLayers()
        }
        
        return alertController
    }
    
}
