//
//  OperationQueueManagerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 18.10.20.
//

import Foundation

protocol OperationQueueManagerProtocol: AnyObject {
    func addOperationToQueue(_ operation: MainThreadOperation)
    
    func suspendQueue(_ isSuspended: Bool)
}
