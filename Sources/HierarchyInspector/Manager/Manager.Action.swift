//
//  Manager.Action.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.10.20.
//

import UIKit

extension HierarchyInspector.Manager {
    
    enum Action {
        case emptyLayer(_ title: String)
        
        case toggleLayer(_ title: String, closure: Closure)
        
        case showAllLayers(closure: Closure)
        
        case hideVisibleLayers(closure: Closure)
        
        case openHierarchyInspector(from: HierarchyInspectorPresentable)
        
        case inspect(vc: HierarchyInspectorPresentable)
        
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
            }
        }
        
        var modifierFlags: UIKeyModifierFlags? {
            switch self {
            case .openHierarchyInspector:
                return HierarchyInspector.configuration.keyCommands.presentationModfifierFlags
            
            case .emptyLayer,
                 .toggleLayer,
                 .showAllLayers,
                 .hideVisibleLayers,
                 .inspect:
                return nil
            }
        }
    }
    
}

extension HierarchyInspector.Manager.Action {
    
    var alertAction: UIAlertAction? {
        switch self {
        case let .emptyLayer(title):
            return UIAlertAction(title: title, style: .default, handler: nil).then {
                $0.isEnabled = false
            }
            
        case let .toggleLayer(_, closure),
             let .showAllLayers(closure),
             let .hideVisibleLayers(closure):
            
            return UIAlertAction(title: title, style: .default) { _ in
               closure()
           }
            
        case let .inspect(vc):
            return UIAlertAction(title: title, style: .default) { _ in
                vc.presentHierarchyInspector(animated: true)
            }
            
        case let .openHierarchyInspector(fromViewController):
            return UIAlertAction(title: title, style: .default) { _ in
                fromViewController.presentHierarchyInspector(animated: true)
            }
        }
    }
    
}
