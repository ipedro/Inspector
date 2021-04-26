//
//  Array+UIKeyCommand.swift
//  
//
//  Created by Pedro on 26.04.21.
//

import UIKit

extension Array where Element == UIKeyCommand {
    func sortedByInputKey() -> Self {
        var copy = self
        copy.sort { lhs, rhs -> Bool in
            guard
                let lhsInput = lhs.input,
                let rhsInput = rhs.input
            else {
                return true
            }
            
            return lhsInput < rhsInput
        }
        
        return copy
    }
}
