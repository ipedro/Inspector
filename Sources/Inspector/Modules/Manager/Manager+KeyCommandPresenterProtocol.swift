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

import UIKit

// MARK: - HierarchyInspector Manager Extension

extension Manager: KeyCommandPresenterProtocol {
    
    private var keyCommandSettings: InspectorConfiguration.KeyCommandSettings {
        Inspector.configuration.keyCommands
    }
    
    var availableGroupsForKeyCommand: CommandGroups {
        guard let host = host else {
            return []
        }
        
        let openInspectorGroup = CommandsGroup(
            title: nil,
            commands: [
                .presentInspector(from: host)
            ]
        )
        
        var commandGroups = [openInspectorGroup]
        commandGroups.append(contentsOf: availableCommandGroups)
        
        return commandGroups
    }
    
    public var keyCommands: [UIKeyCommand] {
        hierarchyInspectorKeyCommands(selector: #selector(UIViewController.inspectorKeyCommandHandler(_:)))
    }
    
    func hierarchyInspectorKeyCommands(selector aSelector: Selector) -> [UIKeyCommand] {
        let keyCommands = availableGroupsForKeyCommand.flatMap { actionGroup in
            actionGroup.commands.compactMap { action -> UIKeyCommand? in
                guard let options = action.keyCommandOptions else {
                    return nil
                }
                
                return UIKeyCommand(.discoverabilityTitle(title: action.title, key: options), action: aSelector)
            }
        }

        return keyCommands.sortedByInputKey()
    }
    
}
