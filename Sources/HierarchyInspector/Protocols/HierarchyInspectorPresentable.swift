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
        presentHierarchyInspector(animated: animated, isInspecting: false)
    }
    
}

// MARK: - ActionSheet Presentation

extension HierarchyInspectorPresentable {
    public var canPresentHierarchyInspector: Bool {
        presentingViewController is UIAlertController == false
    }
    
    func presentHierarchyInspector(animated: Bool, isInspecting: Bool) {
        guard
            canPresentHierarchyInspector,
            let viewHierarchySnapshot = hierarchyInspectorManager.viewHierarchySnapshot
        else {
            return
        }
        
        let start = Date()
        
        let viewController = HierarchyInspectorViewController.create(
            viewModel: HierarchyInspectorViewModel(
                layerActionGroups: hierarchyInspectorManager.availableActions,
                snapshot: viewHierarchySnapshot
            )
        ).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.modalTransitionStyle   = .crossDissolve
        }
        
        present(viewController, animated: true) {
            let elaspedTime = Date().timeIntervalSince(start)
            
            print("Presented Hierarchy Inspector in \(elaspedTime) seconds")
        }
    }
    
    private func makeAlertController(
        with actionGroups: ActionGroups,
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
                    self?.presentHierarchyInspector(animated: true, isInspecting: !inspecting)
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
