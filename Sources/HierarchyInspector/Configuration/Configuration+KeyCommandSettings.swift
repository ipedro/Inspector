//
//  Configuration.KeyCommandSettings.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit
import UIKitOptions

public extension HierarchyInspector.Configuration {

    struct KeyCommandSettings {
        
        public var layerToggleInputRange: ClosedRange<Int> = (1 ... 9)
        
        public var layerToggleModifierFlags: UIKeyModifierFlags = [.control]
        
        public var allLayersToggleInput: String = String(0)
        
        public var presentationOptions: UIKeyCommand.Options = .discoverabilityTitle(
            title: Texts.openHierarchyInspector,
            key: .control(.shift(.key("0")))
        )
        
    }
    
}
