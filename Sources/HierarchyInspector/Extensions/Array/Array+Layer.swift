//
//  Array+Layer.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - Array Extension

extension Array where Element == HierarchyInspector.Layer {
    
    func layer(for keyCommand: UIKeyCommand) -> Element? {
        guard
            let input = keyCommand.input,
            let index = Int(input),
            index > 0,
            index <= count
        else {
            return nil
        }
        
        let layer = self[index - 1]
        
        return layer
    }
    
}
