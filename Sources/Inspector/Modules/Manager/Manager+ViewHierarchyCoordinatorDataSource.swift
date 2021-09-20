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

// MARK: - ViewHierarchyCoordinatorDataSource

extension Manager: ViewHierarchyCoordinatorDataSource {
    var rootView: UIView? { host?.window }

    var viewHierarchyLayers: [Inspector.ViewHierarchyLayer] {
        var layers = host?.inspectorViewHierarchyLayers ?? []

        if layers.firstIndex(of: .allViews) == nil {
            layers.append(.allViews)
        }

        layers.append(.systemViews)
        layers.append(.systemContainers)

        return layers.uniqueValues()
    }

    var viewHierarchyColorScheme: Inspector.ViewHierarchyColorScheme {
        host?.inspectorViewHierarchyColorScheme ?? .default
    }

    var elementLibraries: [InspectorElementLibraryProtocol] {
        var elements = host?.inspectorElementLibraries ?? []
        elements.append(contentsOf: UIKitElementLibrary.allCases)

        return elements
    }
}
