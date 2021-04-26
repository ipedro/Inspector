//
//  KeyCommandPresenterProtocol.swift
//  
//
//  Created by Pedro on 26.04.21.
//

import UIKit

protocol KeyCommandPresenterProtocol {
    var availableActionsForKeyCommand: ActionGroups { get }
    
    var keyCommands: [UIKeyCommand] { get }
    
    func hierarchyInspectorKeyCommands(selector aSelector: Selector) -> [UIKeyCommand]
}
