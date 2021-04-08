//
//  Texts.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import Foundation

enum Texts {
    
    static func inspect(_ name: Any) -> String {
        "Inspect \(String(describing: name))..."
    }
    
    static func inspectableViews(_ viewCount: Int, in className: String) -> String {
        "\(viewCount) inspectable views in \(className)"
    }
    
    static let highlightViews = "Highlight Views"
    
    static let closeInspector = "Close"
    
    static let hideVisibleLayers = "Hide visible layers"
    
    static let hierarchyInspector = "Hierarchy Inspector"
    
    static let noLayers = "No Layers"
    
    static let openHierarchyInspector = "Open Hierarchy Inspector..."
    
    static let openingHierarchyInspector = "Opening..."
    
    static let showAllLayers = "Show all layers"
    
    static let stopInspecting = "Stop inspecting me"
    
}
