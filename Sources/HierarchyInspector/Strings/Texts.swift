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
        switch viewCount {
        case 1:
            return "\(viewCount) inspectable view in \(className)"
            
        default:
            return "\(viewCount) inspectable views in \(className)"
        }
    }
    
    static func allResults(count: Int, in elementName: String) -> String {
        switch count {
        case 1:
            return "\(count) Search result in \(elementName)"
            
        default:
            return "\(count) Search results in \(elementName)"
        }
    }
    
    static func emptyLayer(with description: String) -> String {
        "No \(description) found"
    }
    
    static let viewLayers = "View Layers"
    
    static let closeInspector = "Close"
    
    static let hideVisibleLayers = "Hide all layers"
    
    static let hierarchyInspector = "Hierarchy Inspector"
    
    static let noLayers = "No Layers"
    
    static let openHierarchyInspector = "Open Hierarchy Inspector..."
    
    static let openingHierarchyInspector = "Opening..."
    
    static let showAllLayers = "Show all layers"
    
    static let stopInspecting = "Stop inspecting me"
    
    static let dismissView = "Dismiss View"
}
