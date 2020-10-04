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
        
        public var wireframeLayerColor: UIColor = .systemGray
        
        public var wireframeLayerBorderWidth: CGFloat = 0.5
        
        // MARK: - Empty Layer Style
        
        public var emptyLayerColor: UIColor = .systemGray
        
        public var emptyLayerBorderWidth: CGFloat = 0
    }
    
}
