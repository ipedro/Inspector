//
//  Action.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.10.20.
//

import UIKit

enum Action {
    case emptyLayer(_ title: String)
    
    case toggleLayer(_ title: String, closure: Closure)
    
    case showAllLayers(closure: Closure)
    
    case hideVisibleLayers(closure: Closure)
    
    case openHierarchyInspector(from: HierarchyInspectorPresentable)
    
    case inspect(vc: HierarchyInspectorPresentable)
    
    case inspectWindow(vc: HierarchyInspectorPresentable)
}

// MARK: - Properties

extension Action {
    var isEnabled: Bool {
        guard case .emptyLayer = self else {
            return true
        }
        return false
    }
    
    var title: String {
        switch self {
        case let .emptyLayer(title),
             let .toggleLayer(title, _):
            return title
            
        case .showAllLayers:
            return Texts.showAllLayers
            
        case .hideVisibleLayers:
            return Texts.hideVisibleLayers
            
        case let .inspect(vc):
            return Texts.inspect(String(describing: vc.classForCoder))
            
        case .openHierarchyInspector:
            return Texts.openHierarchyInspector
            
        case let .inspectWindow(fromVC):
            return Texts.inspect(String(describing: fromVC.classForCoder))
        }
    }
    
    var closure: (() -> Void)? {
        switch self {
        case .emptyLayer:
            return nil
            
        case let .toggleLayer(_, closure),
             let .showAllLayers(closure),
             let .hideVisibleLayers(closure):
            return closure
            
        case let .inspect(vc):
            return { vc.presentHierarchyInspector(animated: true) }
            
        case let .openHierarchyInspector(fromViewController):
            return { fromViewController.presentHierarchyInspector(animated: true) }
            
        case let .inspectWindow(vc):
            guard let window = vc.view.window else {
                return nil
            }
            
            return {
                vc.hierarchyInspectorManager.presentElementInspector(
                    for: ViewHierarchyReference(root: window),
                    animated: true,
                    from: nil
                )
            }
        }
    }
}
