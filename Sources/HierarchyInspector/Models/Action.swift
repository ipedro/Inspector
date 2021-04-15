//
//  Action.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.10.20.
//

import UIKit

enum Action {
    case emptyLayer(_ title: String)
    
    case showLayer(_ title: String, closure: Closure)
    
    case hideLayer(_ title: String, closure: Closure)
    
    case showAllLayers(closure: Closure)
    
    case hideVisibleLayers(closure: Closure)
    
    case openHierarchyInspector(from: HierarchyInspectorPresentableViewControllerProtocol)
    
    case inspect(vc: HierarchyInspectorPresentableViewControllerProtocol)
    
    case inspectWindow(vc: HierarchyInspectorPresentableViewControllerProtocol)
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
             let .showLayer(title, _),
             let .hideLayer(title, _):
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
    
    var icon: UIImage? {
        switch self {
        case .emptyLayer:
            return .moduleImage(named: "LayerAction-Empty")
        case .showLayer:
            return .moduleImage(named: "LayerAction-Show")
        case .hideLayer:
            return .moduleImage(named: "LayerAction-Hide")
        case .showAllLayers:
            return .moduleImage(named: "LayerAction-ShowAll")
        case .hideVisibleLayers:
            return .moduleImage(named: "LayerAction-HideAll")
        case .openHierarchyInspector:
            return nil
        case .inspect:
            return nil
        case .inspectWindow:
            return nil
        }
    }
    
    var closure: (() -> Void)? {
        switch self {
        case .emptyLayer:
            return nil
            
        case let .showLayer(_, closure),
             let .hideLayer(_, closure),
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
