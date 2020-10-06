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
    
    static func inspect(_ name: Any) -> String { "Inspect \(String(describing: name))..." }
    
    static let showAllLayers = "Show all layers"
    
    static let hideVisibleLayers = "Hide visible layers"
    
    static let closeInspector = "Close"
    
    static let openHierarchyInspector = "Open Hierarchy Inspector..."
    
    static let noLayers = "No Layers"
    
    static func layers(_ count: Int) -> String { "\(count) Layers" }
}
