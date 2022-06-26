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
    var keyCommands: [UIKeyCommand] {
        if let cachedKeyCommands = keyCommandsStore.wrappedValue {
            return cachedKeyCommands
        }
        let keyCommands = [presentInspectorKeyCommand] + makeKeyCommands(withSelector: keyCommandAction)
        keyCommandsStore.wrappedValue = keyCommands
        return keyCommands
    }

    var commandGroups: CommandsGroups {
        makeCommandGroups(limit: .none)
    }

    var keyCommandAction: Selector {
        #selector(UIViewController.inspectorKeyCommandHandler(_:))
    }

    private var slowAnimationsCommand: Command {
        let totalSpeed = snapshot
            .root
            .windows
            .map(\.layer.speed)
            .reduce(into: 0.0) { partialResult, speed in
                partialResult += speed
            }
        let isSlowingAnimations = totalSpeed < Float(snapshot.root.windows.count)

        return Command(
            title: "Slow Animations",
            icon: .systemIcon("tortoise.fill", weight: .medium),
            keyCommandOptions: .none,
            isSelected: isSlowingAnimations
        ) { [weak self] in
            guard let self = self else { return }
            self.snapshot
                .root
                .windows
                .forEach { $0.layer.speed = isSlowingAnimations ? 1 : 1 / 5 }
        }
    }

    private func makeKeyCommands(withSelector aSelector: Selector) -> [UIKeyCommand] {
        let layerToggleInputRange = Inspector.sharedInstance.configuration.keyCommands.layerToggleInputRange
        let limit = layerToggleInputRange.upperBound - layerToggleInputRange.lowerBound
        let commandGroups = makeCommandGroups(limit: limit)

        return commandGroups
            .map(\.commands)
            .flatMap { $0 }
            .compactMap { command in
                guard let key = command.keyCommandOptions else { return nil }
                return .init(
                    title: command.title,
                    action: aSelector,
                    input: key.input,
                    modifierFlags: key.modifierFlags,
                    discoverabilityTitle: command.title,
                    attributes: command.isEnabled ? .init() : .disabled,
                    state: command.isSelected ? .on : .off
                )
            }
            .sortedByInputKey()
    }

    private var defaultActions: CommandsGroup {
        .group(
            commands: {
                var array = [Command]()
                array.append(slowAnimationsCommand)
                if let toggleWireframesCommand = viewHierarchyCoordinator.toggleWireframesCommand {
                    array.append(toggleWireframesCommand)
                }
                return array
            }()
        )
    }

    private func makeCommandGroups(limit: Int?) -> CommandsGroups {
        var commandGroups: CommandsGroups = []
        if let userCommandGroups = dependencies.customization?.commandGroups {
            if
                userCommandGroups.count == 1,
                var first = userCommandGroups.first,
                first.title == defaultActions.title
            {
                first.commands.append(contentsOf: defaultActions.commands)
                commandGroups.append(first)
            }
            else {
                commandGroups.append(contentsOf: userCommandGroups)
                commandGroups.append(defaultActions)
            }
        }

        commandGroups.append(contentsOf: keyWindowHierarchy)

        commandGroups.append(contentsOf: viewHierarchyCoordinator.commandsGroups(limit: limit))

        return commandGroups
    }

    private var presentInspectorKeyCommand: UIKeyCommand {
        let settings = Inspector.sharedInstance.configuration.keyCommands.presentationSettings
        return .init(
            title: Texts.presentInspector,
            action: #selector(UIViewController.presentationKeyCommandHandler(_:)),
            input: settings.input,
            modifierFlags: settings.modifierFlags
        )
    }

    private var allWindowsHierarchies: CommandsGroups {
        guard let keyWindow = keyWindow else { return [] }

        let snapshot = viewHierarchyCoordinator.latestSnapshot()
        let root = snapshot.root
        let windows = root.children
            .filter { ($0.underlyingView as? UIWindow)?.isKeyWindow == true }

        return windows.map { window in
            .group(
                title: "\(window.underlyingView === keyWindow ? "Key " : "")\(window.displayName) Hierarchy",
                commands: {
                    var commands = [Command]()
                    commands.append(
                        .inspectElement(window) { [weak self] in
                            guard let self = self else { return }
                            self.perform(
                                action: .inspect(preferredPanel: .attributes),
                                with: window,
                                from: keyWindow
                            )
                        }
                    )

                    commands.append(
                        contentsOf: forEach(
                            viewController: root.viewHierarchy
                                .filter { $0.underlyingView?.window === window.underlyingView },
                            .inspect(preferredPanel: .attributes),
                            from: keyWindow
                        )
                    )

                    return commands
                }()
            )
        }
    }

    private var keyWindowHierarchy: CommandsGroups {
        guard let keyWindow = keyWindow else { return [] }
        let snapshot = viewHierarchyCoordinator.latestSnapshot()
        let element = catalog.makeElement(from: keyWindow)
        let root = snapshot.root

        return [
            .group(
                title: "Key \(element.displayName) Hierarchy",
                commands: {
                    var commands = [Command]()
                    commands.append(
                        .inspectElement(element) { [weak self] in
                            guard let self = self else { return }
                            self.perform(
                                action: .inspect(preferredPanel: .attributes),
                                with: element,
                                from: keyWindow
                            )
                        }
                    )

                    commands.append(
                        contentsOf: forEach(
                            viewController: root.viewHierarchy
                                .filter { $0.underlyingView?.window === element.underlyingView },
                            .inspect(preferredPanel: .attributes),
                            from: keyWindow
                        )
                    )

                    return commands
                }()
            )
        ]
    }

    private func forEach(
        viewController viewHierarchy: [ViewHierarchyElementReference],
        _ action: ViewHierarchyElementAction,
        from sourceView: UIView
    ) -> [Command] {
        viewHierarchy
            .compactMap { $0 as? ViewHierarchyElementController }
            .sorted { $0.depth < $1.depth }
            .enumerated()
            .map {
                let (offset, viewController) = $0
                return .inspectElement(
                    viewController,
                    displayName: "\(Array(repeating: " ", count: offset).joined()) \(viewController.displayName)"
                ) { [weak self] in
                    guard let self = self else { return }
                    self.perform(action: action, with: viewController, from: sourceView)
                }
            }
    }
}
