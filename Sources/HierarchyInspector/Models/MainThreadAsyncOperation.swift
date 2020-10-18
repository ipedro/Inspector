//
//  MainThreadAsyncOperation.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 17.10.20.
//

import Foundation

final class MainThreadAsyncOperation: MainThreadOperation {
    
    override func main() {
        DispatchQueue.main.async {
            self.closure()
        }
    }
    
}
