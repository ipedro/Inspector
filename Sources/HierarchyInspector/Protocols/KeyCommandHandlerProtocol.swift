//
//  KeyCommandHandlerProtocol.swift
//  
//
//  Created by Pedro on 26.04.21.
//

import Foundation

@objc public protocol KeyCommandHandlerProtocol {
    
    /// Interprets key commands into HierarchyInspector actions.
    /// - Parameter sender: (Any) If sender is not of `UIKeyCommand` type methods does nothing.
    @objc func hierarchyInspectorKeyCommandHandler(_ sender: Any)
    
}
