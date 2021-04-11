//
//  Configuration.KeyCommandSettings.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public extension HierarchyInspector.Configuration {

    struct KeyCommandSettings {
        
        public let layerToggleInputRange: ClosedRange<Int> = (1 ... 9)
        
        public let layerToggleModifierFlags: UIKeyModifierFlags = [.control]
        
        public let allLayersToggleInput: String = String(0)
        
        public var presentationOptions: UIKeyCommand.Options = .discoverabilityTitle(
            title: Texts.openHierarchyInspector,
            key: .control(.shift(.key("0")))
        )
        
    }
    
}
