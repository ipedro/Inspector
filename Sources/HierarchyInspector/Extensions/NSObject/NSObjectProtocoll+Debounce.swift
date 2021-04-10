//
//  NSObject+Debounce.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 15.10.20.
//

import Foundation

extension NSObjectProtocol where Self: NSObject {
    func debounce(_ selector: Selector, after delay: TimeInterval, object: Any? = nil) {
        Self.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: object)
        
        perform(selector, with: object, afterDelay: delay)
    }
}
