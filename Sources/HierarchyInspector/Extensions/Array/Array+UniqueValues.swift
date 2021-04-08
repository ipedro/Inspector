//
//  Array+UniqueValues.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 04.10.20.
//

import Foundation

extension Array where Element: Equatable {
    var uniqueValues: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        
        return uniqueValues
    }
}
