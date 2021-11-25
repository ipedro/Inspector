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

extension ViewHierarchyCoordinator: ViewHierarchyLayerConstructorProtocol {
    var isShowingLayers: Bool {
        visibleReferences.keys.isEmpty == false
    }

    var isShowingAllPopulatedLayers: Bool {
        let populatedLayers = populatedLayers

        for layer in populatedLayers where isShowingLayer(layer) == false {
            return false
        }

        return true
    }

    var activeLayers: [ViewHierarchyLayer] {
        visibleReferences.compactMap { dict -> ViewHierarchyLayer? in
            guard dict.value.isEmpty == false else {
                return nil
            }

            return dict.key
        }
    }

    var availableLayers: [ViewHierarchyLayer] {
        latestSnapshot()?.availableLayers ?? []
    }

    var populatedLayers: [ViewHierarchyLayer] {
        latestSnapshot()?.populatedLayers ?? []
    }

    // MARK: - Layer Methods

    func isShowingLayer(_ layer: ViewHierarchyLayer) -> Bool {
        activeLayers.contains(layer)
    }

    // MARK: Install

    func installLayer(_ layer: Inspector.ViewHierarchyLayer) {
        guard let snapshot = latestSnapshot() else { return }

        asyncOperation(name: layer.title) {
            self.make(layer: layer, for: snapshot)
        }
    }

    func installAllLayers() {
        guard let snapshot = latestSnapshot() else { return }

        asyncOperation(name: Texts.highlight(Texts.allLayers)) {
            for layer in self.populatedLayers where layer.allowsInternalViews == false {
                self.make(layer: layer, for: snapshot)
            }
        }
    }

    // MARK: Remove

    func removeAllLayers() {
        guard isShowingLayers else {
            return
        }

        asyncOperation(name: Texts.hide(Texts.allLayers)) {
            self.destroyAllLayers()
        }
    }

    func removeLayer(_ layer: ViewHierarchyLayer) {
        guard isShowingLayers else { return }

        asyncOperation(name: layer.title) {
            self.destroy(layer: layer)
        }
    }

    // MARK: - Make

    @discardableResult
    private func make(layer: ViewHierarchyLayer, for snapshot: ViewHierarchySnapshot) -> Bool {
        guard visibleReferences[layer] == nil else {
            return false
        }

        let elementKeys = layer.makeKeysForInspectableElements(in: snapshot)

        visibleReferences.updateValue(elementKeys, forKey: layer)

        return true
    }

    // MARK: - Destroy

    @discardableResult
    private func destroyAllLayers() -> Bool {
        visibleReferences.removeAll()

        return true
    }

    @discardableResult
    private func destroy(layer: ViewHierarchyLayer) -> Bool {
        visibleReferences.removeValue(forKey: layer)

        return true
    }

    // MARK: - LayerView Methods

    func updateLayerViews(to newValue: [ViewHierarchyElementKey: LayerView],
                          from oldValue: [ViewHierarchyElementKey: LayerView])
    {
        let viewReferences = Set(newValue.keys)

        let oldViewReferences = Set(oldValue.keys)

        let removedKeys = oldViewReferences.subtracting(viewReferences)

        let newKeys = viewReferences.subtracting(oldViewReferences)

        removedKeys.forEach { oldKey in
            guard let layerView = oldValue[oldKey] else {
                return
            }

            layerView.removeFromSuperview()
        }

        newKeys.forEach { newKey in
            let reference = newKey.reference

            guard
                let inspectorView = newValue[newKey],
                let underlyingView = reference.underlyingView
            else {
                return
            }

            underlyingView.installView(
                inspectorView,
                .autoResizingMask,
                position: reference.canPresentOnTop && inspectorView.canPresentOnTop ? .inFront : .behind
            )
        }
    }

    // MARK: - Reference Management

    func removeReferences(for removedLayers: Set<ViewHierarchyLayer>,
                          in oldValue: [ViewHierarchyLayer: [ViewHierarchyElementKey]])
    {
        var removedReferences = [ViewHierarchyElementKey]()

        removedLayers.forEach { layer in
            oldValue[layer]?.forEach {
                removedReferences.append($0)
            }
        }

        for (layer, elements) in visibleReferences where layer != .wireframes {
            elements.forEach {
                if let index = removedReferences.firstIndex(of: $0) {
                    removedReferences.remove(at: index)
                }
            }
        }

        removedReferences.forEach { removedReference in
            highlightViews.removeValue(forKey: removedReference)
        }

        if removedLayers.contains(.wireframes) {
            wireframeViews.removeAll()
        }
    }
    
    func removeWireframeView(for key: ViewHierarchyElementKey) {
        wireframeViews[key]?.removeFromSuperview()
        wireframeViews.removeValue(forKey: key)
    }
    
    func removeHighlightView(for key: ViewHierarchyElementKey) {
        highlightViews[key]?.removeFromSuperview()
        highlightViews.removeValue(forKey: key)
    }
    
    func addHighlightView(for key: ViewHierarchyElementKey, with colorScheme: ViewHierarchyColorScheme) {
        guard
            highlightViews[key] == nil,
            let rootView = key.reference.underlyingView
        else {
            return
        }

        let highlightView = HighlightView(
            frame: rootView.bounds,
            name: rootView.elementName,
            colorScheme: colorScheme,
            element: key.reference
        ).then {
            $0.delegate = self
        }

        highlightViews[key] = highlightView
    }
    
    func addWireframeView(for key: ViewHierarchyElementKey, with colorScheme: ViewHierarchyColorScheme) {
        guard
            highlightViews[key] == nil,
            let rootView = key.reference.underlyingView
        else {
            return
        }

        let wireframeView = WireframeView(
            frame: rootView.bounds,
            element: key.reference
        ).then {
            $0.delegate = self
        }

        wireframeViews[key] = wireframeView
    }

    func addReferences(for newLayers: Set<ViewHierarchyLayer>, with colorScheme: ViewHierarchyColorScheme) {
        for newLayer in newLayers {
            guard let elements = visibleReferences[newLayer] else { continue }

            if newLayer.showLabels {
                elements.forEach { addHighlightView(for: $0, with: colorScheme) }
            }
            else {
                elements.forEach { addWireframeView(for: $0, with: colorScheme) }
            }
        }
    }
}
