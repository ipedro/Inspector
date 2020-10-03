//
//  KeyCommands.swift
//  
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

enum KeyCommands {
    
    enum Layers {
        static let tooggleKeyCommandsInputRange: ClosedRange<Int> = 1...9
        
        static let tooggleAllKeyCommandsInput: String = "0"
    }

    enum HierarchyInspector {
        static let presentationModfifierFlags: UIKeyModifierFlags = [.alternate]
        
        static let presentationInput: String = Layers.tooggleAllKeyCommandsInput

    }
    
}
