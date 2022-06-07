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
        var commandGroups = CommandsGroups()
        if let userCommandGroups = dependencies.customization?.commandGroups {
            commandGroups.append(contentsOf: userCommandGroups)
        }
        commandGroups.append(contentsOf: viewHierarchyCommandGroups)
        commandGroups.append(contentsOf: elementCommandGroups)
        return commandGroups
    }

    private var viewHierarchyCommandGroups: CommandsGroups {
        viewHierarchyCoordinator.commandsGroups()
    }

    private var elementCommandGroups: CommandsGroups {
        guard let keyWindow = keyWindow else { return [] }

        let snapshot = viewHierarchyCoordinator.latestSnapshot()
        let root = snapshot.root
        let windows = root.children
            .filter { $0.underlyingView is UIWindow }

        return windows.map { window in
            .group(
                title: "\(window.displayName) Hierarchy",
                commands: {
                    var commands = [Command]()
                    commands.append(
                        .inspectElement(window) { [weak self] in
                            guard let self = self else { return }
                            self.perform(
                                action: .inspect(
                                    preferredPanel: .children
                                ),
                                with: window,
                                from: keyWindow
                            )
                        }
                    )

                    commands.append(
                        contentsOf: forEach(
                            viewController: root.viewHierarchy
                                .filter { $0.underlyingView?.window === window.underlyingView },
                            .inspect(preferredPanel: .children),
                            from: keyWindow
                        )
                    )

                    return commands
                }()
            )
        }
    }

    private func forEach(
        viewController viewHierarchy: [ViewHierarchyElementReference],
        _ action: ViewHierarchyElementAction,
        from sourceView: UIView
    ) -> [Command] {
        viewHierarchy
            .compactMap { $0 as? ViewHierarchyController }
            .sorted { $0.depth < $1.depth }
            .enumerated()
            .map { offset, viewController in
                .inspectElement(
                    viewController,
                    displayName: [
                        Array(repeating: "  ", count: offset + 1).joined(),
                        viewController.displayName
                    ].joined()
                ) { [weak self] in
                    guard let self = self else { return }
                    self.perform(action: action, with: viewController, from: sourceView)
                }
            }
    }
}
