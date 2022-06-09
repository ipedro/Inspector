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
            let elementKeys = element.inspectorHostableViewHierarchy.compactMap { ViewHierarchyElementKey(reference: $0) }

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

    func commandsGroups() -> CommandsGroups {
        let snapshot = latestSnapshot()
        let toggleAllHighlights = toggleAllLayersCommands(for: snapshot)
        let highlights = availableLayerCommands(for: snapshot)
        let wireframes = command(for: .wireframes, at: layerToggleInputRange.lowerBound, isEmpty: false)

        let totalSpeed = snapshot
            .root
            .windows
            .map(\.layer.speed)
            .reduce(into: 0.0) { partialResult, speed in
                partialResult += speed
            }
        let isSlowingAnimations = totalSpeed < Float(snapshot.root.windows.count)

        let slowAnimations = Command(
            title: "Slow Animations",
            icon: .systemIcon("tortoise"),
            keyCommandOptions: .none,
            isSelected: isSlowingAnimations
        ) {
            snapshot
                .root
                .windows
                .forEach { $0.layer.speed = isSlowingAnimations ? 1 : 1 / 5 }
        }

        return [
            .group(
                title: "Commands",
                commands:
                [slowAnimations, wireframes].compactMap { $0 }
                    + toggleAllHighlights
            ),
            .group(
                title: "Highlights",
                commands: highlights
            )
        ]
    }

    private func makeSnapshot() -> ViewHierarchySnapshot {
        let application = ViewHierarchyElementRoot(.shared, catalog: dependencies.catalog)
        let snapshot = ViewHierarchySnapshot(layers: dependencies.layers, root: application)
        return snapshot
    }
}

private extension ViewHierarchyLayer {
    static let highlightViews: ViewHierarchyLayer = .layer(
        name: String(describing: type(of: HighlightView.self))
    ) { _ in
        false
    }
}
