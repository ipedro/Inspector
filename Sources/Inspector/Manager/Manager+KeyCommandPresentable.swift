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

extension Manager: KeyCommandPresentable {
    var commandGroups: CommandsGroups {
        let userCommands = dependencies.customization?.commandGroups ?? []
        let layersCommands = viewHierarchyCoordinator.commandsGroup()
        
        var groups = CommandsGroups()
        groups.append(contentsOf: userCommands)
        if let elementCommands = elementCommands {
            groups.append(elementCommands)
        }
        groups.append(layersCommands)

        return groups
    }
    
    private var elementCommands: CommandsGroup? {
        guard let keyWindow = keyWindow else { return .none }
        
        let commands: [Command] = {
            let snapshot = viewHierarchyCoordinator.latestSnapshot()
            var commands = [Inspector.Command]()
            
            let rootReference = snapshot.root
            commands.append(
                .inspectElement(rootReference, icon: .elementIdentityPanel) { [weak self] in
                    self?.perform(action: .inspect(preferredPanel: .identity), with: rootReference, from: keyWindow)
                }
            )
            
            guard let rootView = snapshot.root.underlyingView else { return commands }
            let rootViewReference = catalog.makeElement(from: rootView)
            commands.append(
                .inspectElement(rootViewReference, icon: .elementChildrenPanel) { [weak self] in
                    self?.perform(action: .inspect(preferredPanel: .children), with: rootViewReference, from: keyWindow)
                }
            )
            
            guard let rootViewController = snapshot.root.underlyingViewController else { return commands }
            let rootViewControllerReference = ViewHierarchyController(rootViewController)
            commands.append(
                .inspectElement(rootViewControllerReference, icon: .elementChildrenPanel) { [weak self] in
                    self?.perform(action: .inspect(preferredPanel: .children), with: rootViewControllerReference, from: keyWindow)
                }
            )
            
            if let selectedTabViewController = (rootViewController as? UITabBarController)?.selectedViewController {
                let tabBarViewControllerReference = ViewHierarchyController(selectedTabViewController)
                commands.append(
                    .inspectElement(
                        tabBarViewControllerReference,
                        displayName: tabBarViewControllerReference.className,
                        icon: .elementChildrenPanel
                    ) { [weak self] in
                        self?.perform(
                            action: .inspect(preferredPanel: .children),
                            with: tabBarViewControllerReference, from: keyWindow)
                    }
                )
            }
            
            return commands
        }()
        
        return .group(title: "Inspect Elements", commands: commands.reversed())
    }
}
