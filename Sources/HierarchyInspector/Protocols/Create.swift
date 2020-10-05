//
//  Create.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import Foundation

protocol Create {}

extension Create where Self: AnyObject {
    
    /// A closure that executes just after the object is initialized.
    ///
    ///     let label = UILabel().then {
    ///       $0.textAlignment = .center
    ///       $0.text = "Hello, World!"
    ///     }
    ///
    /// - Parameter closure: A closure that will be executed.
    func then(_ closure: (Self) throws -> Void) rethrows -> Self {
        try closure(self)
        return self
    }

}
