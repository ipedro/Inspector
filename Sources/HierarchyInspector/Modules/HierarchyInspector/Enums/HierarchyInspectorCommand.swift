//
//  HierarchyInspectorCommand.swift
//  
//
//  Created by Pedro Almeida on 25.04.21.
//

import Foundation

enum HierarchyInspectorCommand {
    case execute(Closure)
    case inspect(ViewHierarchyReference)
}
