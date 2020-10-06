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
        
        hierarchyInspectorManager.asyncOperation(name: "Loading") { [weak self] in
            guard let self = self else {
                return
            }
            
            guard
                let alertController = self.makeAlertController(
                    with: self.hierarchyInspectorManager.availableActions,
                    in: self.hierarchyInspectorManager.viewHierarchySnapshot,
                    inspecting: inspecting
                )
            else {
                return
            }
            
            self.present(alertController, animated: true) {
                let elaspedTime = Date().timeIntervalSince(start)
                
                print("Presented Hierarchy Inspector in \(elaspedTime) seconds")
            }
        }
    }
    
    private func makeAlertController(
        with actionGroups: [HierarchyInspector.Manager.ActionGroup],
        in snapshot: ViewHierarchySnapshot?,
        inspecting: Bool
    ) -> UIAlertController? {
        guard let snapshot = snapshot else {
            return nil
        }
        
        let alertController = UIAlertController(
            title: Texts.hierarchyInspector,
            message: "\(snapshot.flattenedViewHierarchy.count) inspectable views in \(snapshot.viewHierarchy.className)",
            preferredStyle: .alert
        ).then {
            $0.view.tintColor = .systemPurple
        }
        
        // Close button
        alertController.addAction(
            UIAlertAction(title: Texts.closeInspector, style: .cancel, handler: nil)
        )
        
        // Manager actions
        actionGroups.forEach { group in
            group.alertActions.forEach { alertController.addAction($0) }
        }
        
        // Alert controller inspection
        
        #if DEBUG
        if self is UIAlertController == false {
            alertController.addAction(
                UIAlertAction(
                    title: inspecting ? Texts.stopInspecting : Texts.inspect("Hierarchy Inspector"),
                    style: .default
                ) { [weak self] action in
                    self?.presentHierarchyInspector(animated: true, inspecting: !inspecting)
                }
            )
        }
        #endif
        
        if inspecting {
            DispatchQueue.main.async {
                alertController.hierarchyInspectorManager.installAllLayers()
            }
        }
        
        return alertController
    }
    
}
