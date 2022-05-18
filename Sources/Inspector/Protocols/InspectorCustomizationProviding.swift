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

public protocol InspectorCustomizationProviding: AnyObject {
    /// Command groups act as sections on the Inspector interface. You can have as many groups, with as many actions as you would like.
    var commandGroups: [Inspector.CommandsGroup]? { get }

    /// Show your own icons for any of your classes or override any of the default ones.
    var elementIconProvider: Inspector.ElementIconProvider? { get }

    /// Element Libraries are entities that conform to `InspectorElementLibraryProtocol` and represent a section inside an element's inspector panel. You can have multiple sections for the same element type in different `ElementPanelTypes`.
    var elementLibraries: [Inspector.ElementPanelType: [InspectorElementLibraryProtocol]]? { get }

    /// Returns colors associated with view instances, types, or any other conditions you might think of.
    var elementColorProvider: Inspector.ElementColorProvider? { get }

    /// `ViewHierarchyLayer` are toggleable and shown in the `Highlight views` section on the Inspector interface, and also can be triggered with `Ctrl + Shift + 1 - 9`. Add your own custom inspector layers.
    var viewHierarchyLayers: [Inspector.ViewHierarchyLayer]? { get }
}

// MARK: - Swift UI

protocol InspectorSwiftUIHost: InspectorCustomizationProviding {
    func insectorViewWillFinishPresentation()
}
