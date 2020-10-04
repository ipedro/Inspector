//
//  Configuration.KeyCommands.swift
//
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

public extension HierarchyInspector.Configuration {

    struct KeyCommands {
        
        private static let inputRange: ClosedRange<Int> = (0 ... 9)
        
        public let availableCommandsInputRange: ClosedRange<Int> = inputRange.lowerBound + 1 ... inputRange.upperBound
        
        public var presentationModfifierFlags: UIKeyModifierFlags = [.alternate]
        
        public var keyCommandsInputRange: ClosedRange<Int> {
            Self.inputRange
        }
        
        var presentationKeyCommand: String {
            String(keyCommandsInputRange.lowerBound)
        }
    }
    
}
