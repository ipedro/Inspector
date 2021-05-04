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

public protocol InspectorHostable: AnyObject {
    
    var window: UIWindow? { get }
    
    /// Default value is an empty array. `ViewHierarchyLayer` are togglabe and shown in the `Highlight views` section on the Inspector interface, and also can be triggered with `Ctrl + Shift + 1 - 9`. You can create your own or use one of the default ones.
    var inspectorViewHierarchyLayers: [Inspector.ViewHierarchyLayer] { get }
    
    /// Return your own color scheme for the hierarchy label colors, instead of the default color scheme.
    var inspectorViewHierarchyColorScheme: Inspector.ViewHierarchyColorScheme? { get }
    
    /// Default value is an empty array. Action groups appear as sections on the Inspector interface, you can have as many groups, with as many actions as you would like.
    var inspectorCommandGroups: [Inspector.CommandsGroup] { get }
    
    /// Default value is an empty array. Element Libraries are entities that conform to `InspectorElementLibraryProtocol` and are each tied to a unique type. *Pro-tip: Enumerations are recommended.*
    var inspectorElementLibraries: [InspectorElementLibraryProtocol] { get }
    
}

// MARK: - Default Values

public extension InspectorHostable {
    
    var inspectorViewHierarchyLayers: [Inspector.ViewHierarchyLayer] { [] }
    
    var inspectorViewHierarchyColorScheme: Inspector.ViewHierarchyColorScheme? { nil }
    
    var inspectorCommandGroups: [Inspector.CommandsGroup] { [] }
    
    var inspectorElementLibraries: [InspectorElementLibraryProtocol] { [] }
    
}

// MARK: - Convenience

public extension InspectorHostable {

    func presentInspector(animated: Bool) {
        window?.presentInspector(animated: animated)
    }
    
}
