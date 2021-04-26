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

enum Action {
    case emptyLayer(_ title: String)
    
    case showLayer(_ title: String, closure: Closure)
    
    case hideLayer(_ title: String, closure: Closure)
    
    case showAllLayers(closure: Closure)
    
    case hideVisibleLayers(closure: Closure)
    
    case openHierarchyInspector(from: HierarchyInspectableProtocol)
}

// MARK: - Properties

extension Action {
    var isEnabled: Bool {
        guard case .emptyLayer = self else {
            return true
        }
        return false
    }
    
    var title: String {
        switch self {
        case let .emptyLayer(title),
             let .showLayer(title, _),
             let .hideLayer(title, _):
            return title
            
        case .showAllLayers:
            return Texts.showAllLayers
            
        case .hideVisibleLayers:
            return Texts.hideVisibleLayers
            
        case .openHierarchyInspector:
            return Texts.openHierarchyInspector
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .emptyLayer:
            return .moduleImage(named: "LayerAction-Empty")
        case .showLayer:
            return .moduleImage(named: "LayerAction-Show")
        case .hideLayer:
            return .moduleImage(named: "LayerAction-Hide")
        case .showAllLayers:
            return .moduleImage(named: "LayerAction-ShowAll")
        case .hideVisibleLayers:
            return .moduleImage(named: "LayerAction-HideAll")
        case .openHierarchyInspector:
            return nil
        }
    }
    
    var closure: (() -> Void)? {
        switch self {
        case .emptyLayer:
            return nil
            
        case let .showLayer(_, closure),
             let .hideLayer(_, closure),
             let .showAllLayers(closure),
             let .hideVisibleLayers(closure):
            return closure
            
        case let .openHierarchyInspector(from: host):
            return { host.presentHierarchyInspector(animated: true) }
        }
    }
}
