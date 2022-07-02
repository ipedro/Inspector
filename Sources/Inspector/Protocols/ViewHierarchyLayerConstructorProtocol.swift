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

protocol ViewHierarchyLayerConstructorProtocol {
    var isShowingLayers: Bool { get }

    var isShowingAllPopulatedLayers: Bool { get }

    var activeLayers: [ViewHierarchyLayer] { get }

    var availableLayers: [ViewHierarchyLayer] { get }

    var populatedLayers: [ViewHierarchyLayer] { get }

    // MARK: - Layer Methods

    func isShowingLayer(_ layer: ViewHierarchyLayer) -> Bool

    func installLayer(_ layer: Inspector.ViewHierarchyLayer)

    func removeLayer(_ layer: Inspector.ViewHierarchyLayer)

    func installAllLayers()

    func removeAllLayers()

    // MARK: - LayerView Methods

    func updateLayerViews(to newValue: [ViewHierarchyElementKey: LayerView],
                          from oldValue: [ViewHierarchyElementKey: LayerView])

    // MARK: - Element Reference Methods

    func removeReferences(for removedLayers: Set<ViewHierarchyLayer>,
                          in oldValue: [ViewHierarchyLayer: [ViewHierarchyElementKey]])

    func addReferences(for newLayers: Set<ViewHierarchyLayer>,
                       with colorScheme: ViewHierarchyColorScheme)
}

class ViewHierarchyElementKey: Hashable {
    private(set) weak var reference: ViewHierarchyElementReference?
    private let viewIdentifier: ObjectIdentifier

    init?(reference: ViewHierarchyElementReference) {
        guard let viewIdentifier = reference.underlyingView?.objectIdentifier else {
            return nil
        }

        self.reference = reference
        self.viewIdentifier = viewIdentifier
    }

    static func == (lhs: ViewHierarchyElementKey, rhs: ViewHierarchyElementKey) -> Bool {
        lhs.viewIdentifier == rhs.viewIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(viewIdentifier)
    }
}
