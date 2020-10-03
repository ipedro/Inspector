//
//  HiearrachyInspector.Appearance.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public extension HierarchyInspector {
    
    struct Configuration {
        
        public var appearane = Appearance()
        
        public var keyCommands = KeyCommands()
    }
}

public extension HierarchyInspector.Configuration {
    
    struct Appearance {
        
        // MARK: - Wireframe Style
        
        public var wireframeLayerColor: UIColor = .systemGray
        
        public var wireframeLayerBorderWidth: CGFloat = 0.5
        
        // MARK: - Empty Layer Style
        
        public var emptyLayerColor: UIColor = .systemGray
        
        public var emptyLayerBorderWidth: CGFloat = 0
    }
    
    struct KeyCommands {
        
        public struct Layers {
            
            public var tooggleKeyCommandsInputRange: ClosedRange<Int> = 1...9
            
            public var tooggleAllKeyCommandsInput: String = "0"
            
        }
        
        public struct HierarchyInspector {
            
            public var presentationModfifierFlags: UIKeyModifierFlags = [.alternate]
            
            public var presentationInput: String = "0"
            
        }
        
        public var layers = Layers()
        
        public var hierarchyInspector = HierarchyInspector()

    }
    
}
