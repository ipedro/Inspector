//  Copyright (c) 2021 Pedro Almeida
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
    
    /**
     Cancels all queued and executing operations.
     
     This method calls the cancel() method on all operations currently in the queue.
     
     Canceling the operations does not automatically remove them from the queue or stop those that are currently executing. For operations that are queued and waiting execution, the queue must still attempt to execute the operation before recognizing that it is canceled and moving it to the finished state. For operations that are already executing, the operation object itself must check for cancellation and stop what it is doing so that it can move to the finished state. In both cases, a finished (or canceled) operation is still given a chance to execute its completion block before it is removed from the queue.
     */
    func cancelAllOperations()
}
