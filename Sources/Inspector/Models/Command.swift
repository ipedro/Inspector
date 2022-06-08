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

typealias Command = Inspector.Command

public extension Inspector {
    struct Command {
        public typealias Closure = () -> Void

        public var title: String

        public var icon: UIImage?

        public var keyCommandOptions: UIKeyCommand.Options?

        public let isSelected: Bool

        var closure: Closure?

        var isEnabled: Bool {
            closure != nil
        }

        public init(
            title: String,
            icon: UIImage?,
            keyCommandOptions: UIKeyCommand.Options?,
            isSelected: Bool = false,
            closure: Closure?
        ) {
            self.title = title
            self.icon = icon?.resized(.actionIconSize)
            self.keyCommandOptions = keyCommandOptions
            self.isSelected = isSelected
            self.closure = closure
        }
    }
}

// MARK: - Internal Convenience

extension Command {
    private static var keyCommandSettings: InspectorConfiguration.KeyCommandSettings {
        Inspector.sharedInstance.configuration.keyCommands
    }

    static func emptyLayer(_ title: String) -> Command {
        Command(
            title: title,
            icon: .emptyLayerAction,
            keyCommandOptions: nil,
            closure: nil
        )
    }

    static func visibleLayer(_ title: String, at index: Int, closure: @escaping Closure) -> Command {
        .layer(title: title, at: index, isSelected: true, closure: closure)
    }

    static func hiddenLayer(_ title: String, at index: Int, closure: @escaping Closure) -> Command {
        .layer(title: title, at: index, isSelected: false, closure: closure)
    }

    static func layer(title: String, at index: Int, isSelected: Bool, closure: @escaping Closure) -> Command {
        Command(
            title: title,
            icon: .layerAction,
            keyCommandOptions: UIKeyCommand.Options(
                input: String(index),
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            isSelected: isSelected,
            closure: closure
        )
    }

    static func showAllLayers(closure: @escaping Closure) -> Command {
        Command(
            title: Texts.enable(Texts.allHighlights),
            icon: .layerActionAll,
            keyCommandOptions: UIKeyCommand.Options(
                input: keyCommandSettings.allLayersToggleInput,
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }

    static func hideVisibleLayers(closure: @escaping Closure) -> Command {
        Command(
            title: Texts.disable(Texts.allHighlights),
            icon: .layerActionAll,
            keyCommandOptions: UIKeyCommand.Options(
                input: keyCommandSettings.allLayersToggleInput,
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }

    static func presentInspector(from customization: InspectorCustomizationProviding, animated: Bool = true) -> Command {
        Command(
            title: Texts.presentInspector.lowercased(),
            icon: nil,
            keyCommandOptions: keyCommandSettings.presentationSettings.options
        ) {
            Inspector.present(animated: animated)
        }
    }

    static func inspectElement(
        _ element: ViewHierarchyElementReference,
        displayName: String? = .none,
        icon: UIImage? = .none,
        keyCommandOptions: UIKeyCommand.Options? = .none,
        with closure: @escaping Closure
    ) -> Command {
        Command(
            title: displayName ?? element.displayName,
            icon: icon ?? element.iconImage,
            keyCommandOptions: keyCommandOptions,
            closure: closure
        )
    }
}
