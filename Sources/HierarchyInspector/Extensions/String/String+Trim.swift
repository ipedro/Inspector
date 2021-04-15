//
//  File.swift
//  
//
//  Created by Pedro on 15.04.21.
//

import Foundation

extension String {
    var trimmed: String? {
        let trimmedString = trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedString.isEmpty {
            return nil
        }
        
        return trimmedString
    }
}
