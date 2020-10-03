//
//  Layer+KeyCommandable.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - KeyCommandable

extension HierarchyInspector.Layer: KeyCommandable {
    
    var unselectedKeyCommand: String {
        "☑️ Inspect \(description.localizedLowercase)"
    }
    
    var selectedKeyCommand: String {
        "✅ Inspecting \(description.localizedLowercase)"
    }
    
}
