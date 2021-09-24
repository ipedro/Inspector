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

extension Manager: ViewHierarchyLayerManagerProtocol {
    var isShowingLayers: Bool {
        viewHierarchyCoordinator.isShowingLayers
    }

    func isShowingLayer(_ layer: ViewHierarchyLayer) -> Bool {
        viewHierarchyCoordinator.isShowingLayer(layer)
    }

    func toggleLayer(_ layer: Inspector.ViewHierarchyLayer) {
        if viewHierarchyCoordinator.isShowingLayer(layer) {
            viewHierarchyCoordinator?.removeLayer(layer)
        }
        else {
            viewHierarchyCoordinator?.installLayer(layer)
        }
    }

    func removeLayer(_ layer: Inspector.ViewHierarchyLayer) {
        if viewHierarchyCoordinator.isShowingLayer(layer) {
            viewHierarchyCoordinator?.removeLayer(layer)
        }
    }

    func toggleAllLayers() {
        if viewHierarchyCoordinator.isShowingAllPopulatedLayers {
            viewHierarchyCoordinator?.removeAllLayers()
        }
        else {
            viewHierarchyCoordinator?.installAllLayers()
        }
    }

    func removeAllLayers() {
        viewHierarchyCoordinator?.removeAllLayers()
    }
}

extension Optional where Wrapped: ViewHierarchyCoordinator {
    var isShowingLayers: Bool {
        switch self {
        case .none:
            return false
        case let .some(coordinator):
            return coordinator.isShowingLayers
        }
    }

    var isShowingAllPopulatedLayers: Bool {
        switch self {
        case .none:
            return false
        case let .some(coordinator):
            return coordinator.isShowingAllPopulatedLayers
        }
    }

    func isShowingLayer(_ layer: ViewHierarchyLayer) -> Bool {
        switch self {
        case .none:
            return false
        case let .some(coordinator):
            return coordinator.isShowingLayer(layer)
        }
    }
}
