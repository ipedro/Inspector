//
//  AsyncOperationProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 17.10.20.
//

import Foundation

protocol AsyncOperationProtocol {
    func asyncOperation(name: String, execute closure: @escaping Closure)
}
