//
//  IndexPath+Convenience.swift
//  HierarhcyInspector
//
//  Created by Pedro on 10.04.21.
//

import Foundation

extension IndexPath {
    
    enum InvalidReason: Error {
        case sectionBelowBounds, sectionAboveBounds, rowBelowBounds, rowAboveBounds
    }
    
    static var first = IndexPath(row: .zero, section: .zero)
    
    func previousRow() -> IndexPath {
        IndexPath(row: row - 1, section: section)
    }
    
    func nextRow() -> IndexPath {
        IndexPath(row: row + 1, section: section)
    }
    
    func nextSection() -> IndexPath {
        IndexPath(row: .zero, section: section + 1)
    }
}
