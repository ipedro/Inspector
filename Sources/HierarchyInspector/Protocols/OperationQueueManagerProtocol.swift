//
//  OperationQueueManagerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 18.10.20.
//

import Foundation

protocol OperationQueueManagerProtocol: AnyObject {
    
    /**
     Adds the specified operation to the receiver's operation queue.
     
     Once added, the specified operation remains in the queue until it finishes executing.
     
     An operation object can be in at most one operation queue at a time and this method throws an `invalidArgumentException` exception if the operation is already in another queue. Similarly, this method throws an `invalidArgumentException` exception if the operation is currently executing or has already finished executing.
     */
    func addOperationToQueue(_ operation: MainThreadOperation)
    
    /**
     A Boolean value indicating whether the receiver's queue is actively scheduling operations for execution.
     
     When the value of this property is false, the queue actively starts operations that are in the queue and ready to execute. Setting this property to true prevents the queue from starting any queued operations, but already executing operations continue to execute. You may continue to add operations to a queue that is suspended but those operations are not scheduled for execution until you change this property to false.
     
     Operations are removed from the queue only when they finish executing. However, in order to finish executing, an operation must first be started. Because a suspended queue does not start any new operations, it does not remove any operations (including cancelled operations) that are currently queued and not executing.
     */
    func suspendQueue(_ isSuspended: Bool)
}
