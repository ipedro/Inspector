//
//  ElementInspector.ViewHierarchyInspectorAction.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import Foundation

extension ElementInspector {
    enum ViewHierarchyInspectorAction {
        case inserted([IndexPath])
        case deleted([IndexPath])
        
        var lastIndexPath: IndexPath? {
            switch self {
                case let .inserted(indexPaths),
                     let .deleted(indexPaths):
                    return indexPaths.last
            }
        }
    }
}
