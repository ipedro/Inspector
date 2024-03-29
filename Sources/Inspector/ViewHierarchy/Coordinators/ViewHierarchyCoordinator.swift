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

@_implementationOnly import Coordinator
import UIKit

typealias ViewHierarchyCoordinatorDelegate = ViewHierarchyActionableProtocol & AnyObject

struct ViewHierarchyDependencies {
    var catalog: ViewHierarchyElementCatalog
    var colorScheme: ViewHierarchyColorScheme
    var layers: [ViewHierarchyLayer]
}

final class ViewHierarchyCoordinator: Coordinator<ViewHierarchyDependencies, OperationQueue, Void> {
    let layerToggleInputRange = Inspector.sharedInstance.configuration.keyCommands.layerToggleInputRange

    weak var delegate: ViewHierarchyCoordinatorDelegate?

    private var cachedSnapshot: ViewHierarchySnapshot?

    var wireframeViews: [ViewHierarchyElementKey: WireframeView] = [:] {
        didSet {
            updateLayerViews(to: wireframeViews, from: oldValue)
        }
    }

    var highlightViews: [ViewHierarchyElementKey: LayerView] = [:] {
        didSet {
            updateLayerViews(to: highlightViews, from: oldValue)
        }
    }

    var visibleReferences: [ViewHierarchyLayer: [ViewHierarchyElementKey]] = [:] {
        didSet {
            let layers = Set<ViewHierarchyLayer>(visibleReferences.keys)
            let oldLayers = Set<ViewHierarchyLayer>(oldValue.keys)
            let newLayers = layers.subtracting(oldLayers)
            let removedLayers = oldLayers.subtracting(layers)

            removeReferences(for: removedLayers, in: oldValue)
            addReferences(for: newLayers, with: dependencies.colorScheme)
        }
    }
}

// MARK: - DismissablePresentationProtocol

extension ViewHierarchyCoordinator: DismissablePresentationProtocol {
    func dismissPresentation(animated: Bool) {
        clearData()
    }
}

// MARK: - ViewHierarchyActionableProtocol

extension ViewHierarchyCoordinator: ViewHierarchyActionableProtocol {
    func canPerform(action: ViewHierarchyElementAction) -> Bool {
        switch action {
        case .layer: return true
        case .inspect, .copy: return false
        }
    }

    func perform(action: ViewHierarchyElementAction, with element: ViewHierarchyElementReference, from sourceView: UIView) {
        guard
            canPerform(action: action),
            case let .layer(layerAction) = action
        else {
            delegate?.perform(action: action, with: element, from: sourceView)
            return
        }

        switch layerAction {
        case .showHighlight:
            let snapshot = latestSnapshot()

            // mudar para pegar as referencias somente das layers populadas ao inves de todas as views, ou criar outro comando especifico(?)
            let elementKeys = snapshot.populatedLayers
                .flatMap { layer, _ in
                    layer.filter(viewHierarchy: element.inspectorHostableViewHierarchy)
                }
                .compactMap(ViewHierarchyElementKey.init(reference:))

            if var referenceKeys = visibleReferences[.highlightViews] {
                referenceKeys.append(contentsOf: elementKeys)
                visibleReferences[.highlightViews] = referenceKeys
                elementKeys.forEach { addHighlightView(for: $0, with: dependencies.colorScheme) }

                installLayer(.highlightViews)
            }
            else {
                visibleReferences.updateValue(elementKeys, forKey: .highlightViews)
            }

        case .hideHighlight:
            let elementKeys = element.inspectorHostableViewHierarchy.compactMap { ViewHierarchyElementKey(reference: $0) }
            elementKeys.forEach { removeHighlightView(for: $0) }

            if visibleReferences[.highlightViews].isNilOrEmpty {
                removeLayer(.highlightViews)
            }
        }
    }
}

// MARK: - Internal Interface

extension ViewHierarchyCoordinator {
    func clearData() {
        cachedSnapshot = .none
        visibleReferences.removeAll()
        wireframeViews.removeAll()
        highlightViews.removeAll()
    }

    func latestSnapshot() -> ViewHierarchySnapshot {
        if let cachedSnapshot = cachedSnapshot, cachedSnapshot.isValid { return cachedSnapshot }
        let snapshot = makeSnapshot()
        cachedSnapshot = snapshot
        return snapshot
    }

    func commandsGroups(limit: Int?) -> CommandsGroups {
        let snapshot = latestSnapshot()
        let allHighlights = toggleAllLayersCommands(for: snapshot)
        var highlights = availableLayerCommands(for: snapshot)
        let wireframes = toggleWireframes()

        if let limit = limit {
            highlights = Array(highlights.prefix(limit))
        }

        return [
            .group(
                commands: [wireframes]
            ),
            .group(
                title: "Element Queries",
                commands: allHighlights + highlights
            )
        ]
    }

    private func toggleWireframes() -> Command {
        command(for: .wireframes, at: layerToggleInputRange.lowerBound)
    }

    private func makeSnapshot() -> ViewHierarchySnapshot {
        let application = ViewHierarchyRoot(.shared, catalog: dependencies.catalog)
        let snapshot = ViewHierarchySnapshot(layers: dependencies.layers, root: application)
        return snapshot
    }
}

private extension ViewHierarchyLayer {
    static let highlightViews: ViewHierarchyLayer = .layer(
        name: "Highlight Elements"
    ) { _ in
        false
    }
}
