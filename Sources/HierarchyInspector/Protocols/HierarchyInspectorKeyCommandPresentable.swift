//
//  HierarchyInspectorKeyCommandPresentable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

public protocol HierarchyInspectorKeyCommandPresentable: UIViewController {}

public extension HierarchyInspectorKeyCommandPresentable {
    
    func addHierarchyInspectorKeyCommands() {
        hierarchyInspectorManager?.keyCommands.forEach { addKeyCommand($0) }
    }
    
}
