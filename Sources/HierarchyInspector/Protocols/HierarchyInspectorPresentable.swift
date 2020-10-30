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
        
        guard
            let alertController = makeAlertController(
                with: hierarchyInspectorManager.availableActions,
                in: hierarchyInspectorManager.viewHierarchySnapshot,
                inspecting: inspecting
            )
        else {
            return
        }
        
        present(alertController, animated: true) {
            let elaspedTime = Date().timeIntervalSince(start)
            
            print("Presented Hierarchy Inspector in \(elaspedTime) seconds")
        }
    }
    
    private func makeAlertController(
        with actionGroups: [ActionGroup],
        in snapshot: ViewHierarchySnapshot?,
        inspecting: Bool
    ) -> UIAlertController? {
        guard let snapshot = snapshot else {
            return nil
        }
        
        let alertController = UIAlertController(
            title: Texts.hierarchyInspector,
            message: Texts.inspectableViews(snapshot.flattenedViewHierarchy.count, in: snapshot.viewHierarchy.className),
            preferredStyle: .alert
        ).then {
            #if swift(>=5.0)
            if #available(iOS 13.0, *) {
                $0.overrideUserInterfaceStyle = .dark
            }
            #endif
            
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
                    title: inspecting ? Texts.stopInspecting : Texts.inspect(alertController.classForCoder),
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
