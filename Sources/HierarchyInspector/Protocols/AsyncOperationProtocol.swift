//
//  AsyncOperationProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 17.10.20.
//

import Foundation

protocol AsyncOperationProtocol {
    
    var operationQueue: OperationQueue { get }
    
    func asyncOperation(name: String, execute closure: @escaping Closure)
    
}

extension AsyncOperationProtocol {
    
    func asyncOperation(execute closure: @escaping Closure) {
        asyncOperation(name: #function, execute: closure)
    }
    
}
