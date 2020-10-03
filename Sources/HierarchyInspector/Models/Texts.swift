//
//  Texts.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import Foundation

enum Texts {
    
    static let hierarchyInspector = "🧬\nHierarchy Inspector"
    
    static let stopInspecting = "Stop inspecting me"
    
    static func inspect(_ name: String) -> String { "Inspect \(name)..." }
    
    static let showAllLayers = "Show all layers"
    
    static let hideAllLayers = "Hide all layers"
    
    static let closeInspector = "Close"
    
    static let openHierarchyInspector = "Open Hierarchy Inspector..."
}
