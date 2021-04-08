//
//  Optional+NilOrEmpty.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 30.10.20.
//

import Foundation

extension Optional where Wrapped: Collection {
    
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
    
}
