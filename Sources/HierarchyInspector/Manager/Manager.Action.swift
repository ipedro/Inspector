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
        
        var title: String {
            switch self {
            case let .emptyLayer(title),
                 let .toggleLayer(title, _):
                return title
                
            case .showAllLayers:
                return Texts.showAllLayers
                
            case .hideVisibleLayers:
                return Texts.hideVisibleLayers
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
        }
    }
    
}
