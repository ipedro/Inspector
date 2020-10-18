//
//  MainThreadOperation.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 17.10.20.
//

import Foundation

final class MainThreadOperation: Operation {
    let closure: Closure
    
    init(name: String, closure: @escaping Closure) {
        self.closure = closure
        
        super.init()
        
        self.name = name
    }
    
    override func main() {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                self.closure()
            }
            return
        }
        
        closure()
    }
}