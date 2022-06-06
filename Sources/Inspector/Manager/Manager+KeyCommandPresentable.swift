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
        var groups = CommandsGroups()
        
        let userCommands = dependencies.customization?.commandGroups ?? []
        groups.append(contentsOf: userCommands)
        
        if let elementCommands = elementCommands {
            groups.append(elementCommands)
        }
        
        let layersCommands = viewHierarchyCoordinator.commandsGroup()
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
                .inspectElement(rootReference) { [weak self] in
                    self?.perform(
                        action: .inspect(preferredPanel: .identity),
                        with: rootReference,
                        from: keyWindow
                    )
                }
            )
            
            guard let rootView = snapshot.root.underlyingView else { return commands }
            let rootViewReference = catalog.makeElement(from: rootView)
            commands.append(
                .inspectElement(rootViewReference) { [weak self] in
                    self?.perform(
                        action: .inspect(preferredPanel: .identity),
                        with: rootViewReference,
                        from: keyWindow
                    )
                }
            )
            
            guard let rootViewController = snapshot.root.underlyingViewController else { return commands }
            let rootViewControllerReference = catalog.makeElement(from: rootViewController)
            commands.append(
                .inspectElement(rootViewControllerReference) { [weak self] in
                    self?.perform(
                        action: .inspect(preferredPanel: .identity),
                        with: rootViewControllerReference,
                        from: keyWindow
                    )
                }
            )
            guard let selectedTabViewController = (rootViewController as? UITabBarController)?.selectedViewController else { return commands }
            let selectedTabViewControllerReference = catalog.makeElement(from: selectedTabViewController)
            commands.append(
                .inspectElement(
                    selectedTabViewControllerReference,
                    displayName: selectedTabViewControllerReference.className
                ) { [weak self] in
                    self?.perform(
                        action: .inspect(preferredPanel: .identity),
                        with: selectedTabViewControllerReference,
                        from: keyWindow
                    )
                }
            )
            
            guard let viewController = (selectedTabViewController as? UINavigationController)?.topViewController else { return commands }
            let viewControllerReference = catalog.makeElement(from: viewController)
            commands.append(
                .inspectElement(
                    viewControllerReference,
                    displayName: viewControllerReference.className
                ) { [weak self] in
                    self?.perform(
                        action: .inspect(preferredPanel: .identity),
                        with: viewControllerReference,
                        from: keyWindow
                    )
                }
            )
            
            return commands
        }()
        
        return .group(title: "Inspect Elements", commands: commands.reversed())
    }
}
