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

        let inspectableReferences = layer.inspectableReferences(in: snapshot)

        visibleReferences.updateValue(inspectableReferences, forKey: layer)

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

        if Array(visibleReferences.keys) == [.wireframes] {
            visibleReferences.removeValue(forKey: .wireframes)
        }

        return true
    }

    // MARK: - LayerView Methods

    func updateLayerViews(to newValue: [ViewHierarchyElement: LayerView],
                          from oldValue: [ViewHierarchyElement: LayerView])
    {
        let viewReferences = Set<ViewHierarchyElement>(newValue.keys)

        let oldViewReferences = Set<ViewHierarchyElement>(oldValue.keys)

        let removedReferences = oldViewReferences.subtracting(viewReferences)

        let newReferences = viewReferences.subtracting(oldViewReferences)

        removedReferences.forEach {
            guard let layerView = oldValue[$0] else {
                return
            }

            layerView.removeFromSuperview()
        }

        newReferences.forEach {
            guard
                let referenceView = $0.rootView,
                let inspectorView = newValue[$0]
            else {
                return
            }

            referenceView.installView(inspectorView, .autoResizingMask)
        }
    }

    // MARK: - Reference Management

    func removeReferences(for removedLayers: Set<ViewHierarchyLayer>,
                          in oldValue: [ViewHierarchyLayer: [ViewHierarchyElement]])
    {
        var removedReferences = [ViewHierarchyElement]()

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

    func addReferences(for newLayers: Set<ViewHierarchyLayer>, with colorScheme: ViewHierarchyColorScheme) {
        for newLayer in newLayers {
            guard let elements = visibleReferences[newLayer] else {
                continue
            }

            switch newLayer.showLabels {
            case true:
                elements.forEach { element in
                    guard
                        highlightViews[element] == nil,
                        let rootView = element.rootView
                    else {
                        return
                    }

                    let highlightView = HighlightView(
                        frame: rootView.bounds,
                        name: rootView.elementName,
                        colorScheme: colorScheme,
                        element: element
                    ).then {
                        $0.delegate = self
                    }

                    highlightViews[element] = highlightView
                }

            case false:
                elements.forEach { element in
                    guard
                        highlightViews[element] == nil,
                        let rootView = element.rootView
                    else {
                        return
                    }

                    let wireframeView = WireframeView(
                        frame: rootView.bounds,
                        element: element
                    ).then {
                        $0.delegate = self
                    }

                    wireframeViews[element] = wireframeView
                }
            }
        }
    }
}
