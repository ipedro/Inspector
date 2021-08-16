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

extension Inspector {
    public struct Command {
        public typealias Closure = () -> Void
        
        public var title: String
        
        public var icon: UIImage?
        
        public var keyCommandOptions: UIKeyCommand.Options?
        
        var closure: Closure?
        
        var isEnabled: Bool {
            closure != nil
        }
        
        public init(
            title: String,
            icon: UIImage?,
            keyCommandOptions: UIKeyCommand.Options?,
            closure: Closure?
        ) {
            self.title = title
            self.icon = icon?.resized(.actionIconSize)
            self.keyCommandOptions = keyCommandOptions
            self.closure = closure

        }
    }
}

// MARK: - Internal Convenience

extension Command {
    private static var keyCommandSettings: InspectorConfiguration.KeyCommandSettings {
        Inspector.configuration.keyCommands
    }
    
    static func emptyLayer(_ title: String) -> Command {
        Command(
            title: title,
            icon: .moduleImage(named: "LayerAction-Empty"),
            keyCommandOptions: nil,
            closure: nil
        )
    }
    
    static func showLayer(_ title: String, at index: Int, closure: @escaping Closure) -> Command {
        Command(
            title: title,
            icon: .moduleImage(named: "LayerAction-Show"),
            keyCommandOptions: UIKeyCommand.Options(
                input: String(index),
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }
    
    static func hideLayer(_ title: String, at index: Int, closure: @escaping Closure) -> Command {
        Command(
            title: title,
            icon: .moduleImage(named: "LayerAction-Hide"),
            keyCommandOptions: UIKeyCommand.Options(
                input: String(index),
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }
    
    static func showAllLayers(closure: @escaping Closure) -> Command {
        Command(
            title: Texts.showAllLayers,
            icon: .moduleImage(named: "LayerAction-ShowAll"),
            keyCommandOptions: UIKeyCommand.Options(
                input: keyCommandSettings.allLayersToggleInput,
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }
    
    static func hideVisibleLayers(closure: @escaping Closure) -> Command {
        Command(
            title: Texts.hideAllLayers,
            icon: .moduleImage(named: "LayerAction-HideAll"),
            keyCommandOptions: UIKeyCommand.Options(
                input: keyCommandSettings.allLayersToggleInput,
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }
    
    static func presentInspector(from host: InspectorHostable, animated: Bool = true) -> Command {
        Command(
            title: Texts.presentInspector,
            icon: nil,
            keyCommandOptions: keyCommandSettings.presentationSettings.options
        ) {
            host.presentInspector(animated: animated)
        }
    }
}
