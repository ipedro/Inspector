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

struct Action {
    typealias Closure = () -> Void
    
    var title: String
    
    var icon: UIImage?
    
    var closure: Closure?
    
    var keyCommandOptions: UIKeyCommand.Options?
    
    var isEnabled: Bool {
        closure != nil
    }
    
    init(title: String, icon: UIImage?, keyCommand: UIKeyCommand.Options?, closure: Closure?) {
        self.title = title
        self.icon = icon
        self.keyCommandOptions = keyCommand
        self.closure = closure
    }
}

// MARK: - Internal Convenience

extension Action {
    private static var keyCommandSettings: HierarchyInspectorConfiguration.KeyCommandSettings {
        HierarchyInspector.configuration.keyCommands
    }
    
    static func emptyLayer(_ title: String) -> Action {
        Action(
            title: title,
            icon: .moduleImage(named: "LayerAction-Empty"),
            keyCommand: nil,
            closure: nil
        )
    }
    
    static func showLayer(_ title: String, at index: Int, closure: @escaping Closure) -> Action {
        Action(
            title: title,
            icon: .moduleImage(named: "LayerAction-Show"),
            keyCommand: UIKeyCommand.Options(
                input: String(index),
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }
    
    static func hideLayer(_ title: String, at index: Int, closure: @escaping Closure) -> Action {
        Action(
            title: title,
            icon: .moduleImage(named: "LayerAction-Hide"),
            keyCommand: UIKeyCommand.Options(
                input: String(index),
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }
    
    static func showAllLayers(closure: @escaping Closure) -> Action {
        Action(
            title: Texts.showAllLayers,
            icon: .moduleImage(named: "LayerAction-ShowAll"),
            keyCommand: UIKeyCommand.Options(
                input: keyCommandSettings.allLayersToggleInput,
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }
    
    static func hideVisibleLayers(closure: @escaping Closure) -> Action {
        Action(
            title: Texts.hideVisibleLayers,
            icon: .moduleImage(named: "LayerAction-HideAll"),
            keyCommand: UIKeyCommand.Options(
                input: keyCommandSettings.allLayersToggleInput,
                modifierFlags: keyCommandSettings.layerToggleModifierFlags
            ),
            closure: closure
        )
    }
    
    static func openHierarchyInspector(from host: HierarchyInspectableProtocol, animated: Bool = true) -> Action {
        Action(title: Texts.openHierarchyInspector, icon: nil, keyCommand: keyCommandSettings.presentationOptions) {
            host.presentHierarchyInspector(animated: animated)
        }
    }
}
