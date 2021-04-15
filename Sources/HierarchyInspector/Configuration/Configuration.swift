//
//  Configuration.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.10.20.
//

import Foundation

public extension HierarchyInspector {
    
    struct Configuration {
        
        public var appearance = Appearance()
        
        public var keyCommands = KeyCommandSettings()
        
        public var cacheExpirationTimeInterval: TimeInterval = 0.5
        
    }
}
