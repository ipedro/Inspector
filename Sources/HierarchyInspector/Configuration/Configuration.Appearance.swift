//
//  Configuration.Appearance.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public extension HierarchyInspector.Configuration {
    
    struct Appearance {
        
        // MARK: - Wireframe Style
        
        public var wireframeLayerColor: UIColor = {
            if #available(iOS 13.0, *) {
                return .tertiarySystemFill
            }
            
            return .systemGray
        }()
        
        public var wireframeLayerBorderWidth: CGFloat = 0.5
        
        // MARK: - Empty Layer Style
        
        public lazy var emptyLayerColor: UIColor = wireframeLayerColor
        
        public var emptyLayerBorderWidth: CGFloat = 0
    }
    
}
