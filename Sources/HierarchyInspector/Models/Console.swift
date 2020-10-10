//
//  Console.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import Foundation

public enum Console {
    public static var showDebugLogs: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard showDebugLogs else {
            return
        }
        
        Swift.print(
            [Date()] + items,
            separator: separator,
            terminator: terminator
        )
    }
}
