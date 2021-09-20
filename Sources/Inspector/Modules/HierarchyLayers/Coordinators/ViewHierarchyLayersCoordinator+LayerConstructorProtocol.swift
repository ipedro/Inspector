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

// MARK: - LayerConstructorProtocol

extension ViewHierarchyLayersCoordinator: LayerConstructorProtocol {
    func isShowingLayer(_ layer: ViewHierarchyLayer) -> Bool {
        activeLayers.contains(layer)
    }

    // MARK: - Create

    @discardableResult
    func create(layer: ViewHierarchyLayer, for viewHierarchySnapshot: ViewHierarchySnapshot) -> Bool {
        guard visibleReferences[layer] == nil else {
            return false
        }

        if layer != .wireframes, visibleReferences.keys.contains(.wireframes) == false {
            create(layer: .wireframes, for: viewHierarchySnapshot)
        }

        let filteredHirerarchy = layer.filter(snapshot: viewHierarchySnapshot)

        let viewHierarchyRefences = filteredHirerarchy.map { ViewHierarchyReference(root: $0) }

        visibleReferences.updateValue(viewHierarchyRefences, forKey: layer)

        return true
    }

    // MARK: - Destroy

    @discardableResult
    func destroyAllLayers() -> Bool {
        visibleReferences.removeAll()

        return true
    }

    @discardableResult
    func destroy(layer: ViewHierarchyLayer) -> Bool {
        visibleReferences.removeValue(forKey: layer)

        if Array(visibleReferences.keys) == [.wireframes] {
            visibleReferences.removeValue(forKey: .wireframes)
        }

        return true
    }
}
