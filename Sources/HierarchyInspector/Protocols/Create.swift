//
//  Create.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import Foundation

protocol Create { }

extension Create where Self: AnyObject {

    /// Makes it available to set properties with closures just after initializing.
    ///
    ///     let label = UILabel().then {
    ///       $0.textAlignment = .center
    ///       $0.textColor = UIColor.blackColor()
    ///       $0.text = "Hello, World!"
    ///     }
    func then(_ closure: (Self) throws -> Void) rethrows -> Self {
        try closure(self)
        return self
    }

}

extension NSObject: Create {}
