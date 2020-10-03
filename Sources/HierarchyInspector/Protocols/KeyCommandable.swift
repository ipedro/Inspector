//
//  KeyCommandable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import Foundation

protocol KeyCommandable {
    
    var unselectedKeyCommand: String { get }
    
    var selectedKeyCommand: String { get }
    
    var emptyText: String { get }
    
}
