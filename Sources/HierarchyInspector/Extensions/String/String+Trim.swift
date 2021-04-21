//
//  String+Trim.swift
//  HierarchyInspector
//
//  Created by Pedro on 15.04.21.
//

import Foundation

extension String {
    var trimmed: String? {
        let trimmedString = trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimmedString.isEmpty ? nil : trimmedString
    }
}
