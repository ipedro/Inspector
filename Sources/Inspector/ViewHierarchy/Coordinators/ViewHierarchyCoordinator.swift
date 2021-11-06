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

protocol ViewHierarchyCoordinatorDataSource: AnyObject {
    var windows: [UIWindow] { get }

    var keyWindow: UIWindow? { get }

    var rootViewController: UIViewController? { get }

    var layers: [ViewHierarchyLayer] { get }

    var colorScheme: ViewHierarchyColorScheme { get }

    var catalog: ViewHierarchyElementCatalog { get }
}

final class ViewHierarchyCoordinator: Coordinator {
    // MARK: - Properties

    weak var delegate: ViewHierarchyCoordinatorDelegate?

    weak var dataSource: ViewHierarchyCoordinatorDataSource?

    let operationQueue = OperationQueue.main

    private var cachedSnapshot: ViewHierarchySnapshot? { history.last }

    private lazy var history: [ViewHierarchySnapshot] = []

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

            guard let dataSource = dataSource else { return }

            addReferences(for: newLayers, with: dataSource.colorScheme)
        }
    }

    // MARK: - Init

    init(
        dataSource: ViewHierarchyCoordinatorDataSource?,
        delegate: ViewHierarchyCoordinatorDelegate?
    ) {
        self.dataSource = dataSource
        self.delegate = delegate
    }

    func start() {}
}

// MARK: - DismissablePresentationProtocol

extension ViewHierarchyCoordinator: DismissablePresentationProtocol {
    func dismissPresentation(animated: Bool) {
        clearData()
    }
}

// MARK: - ViewHierarchyActionableProtocol

extension ViewHierarchyCoordinator: ViewHierarchyActionableProtocol {
    func canPerform(action: ViewHierarchyAction) -> Bool {
        switch action {
        case .layer:
            return true

        case .inspect, .copy:
            return false
        }
    }

    func perform(action: ViewHierarchyAction, with element: ViewHierarchyElementReference, from sourceView: UIView) {
        guard
            canPerform(action: action),
            case let .layer(layerAction) = action
        else {
            delegate?.perform(action: action, with: element, from: sourceView)
            return
        }

        switch layerAction {
        case .showHighlight:
            showHighlight(true, for: element)

        case .hideHighlight:
            showHighlight(false, for: element)
        }
    }
}

// MARK: - Internal Interface

extension ViewHierarchyCoordinator {
    func clearData() {
        history.removeAll()
        visibleReferences.removeAll()
        wireframeViews.removeAll()
        highlightViews.removeAll()
    }

    func latestSnapshot() -> ViewHierarchySnapshot? {
        if cachedSnapshot?.isValid == true { return cachedSnapshot }

        guard let snapshot = makeSnapshot() else { return nil }

        history.append(snapshot)

        return snapshot
    }

    func commandGroups() -> CommandGroups? {
        guard let snapshot = latestSnapshot() else { return nil }

        var commands = CommandGroups()
        commands.append(toggleAllLayersCommands(for: snapshot))
        commands.append(availableLayerCommands(for: snapshot))

        return commands
    }

    private func makeSnapshot() -> ViewHierarchySnapshot? {
        guard
            let dataSource = dataSource,
            let root = ViewHierarchyRootReference(windows: dataSource.windows, catalog: dataSource.catalog)
        else {
            return nil
        }
        
        let snapshot = ViewHierarchySnapshot(
            layers: dataSource.layers,
            root: root
        )
        
        return snapshot
    }

    func showHighlight(
        _ show: Bool,
        for element: ViewHierarchyElementReference,
        includeSubviews: Bool = true
    ) {

        guard let key = ViewHierarchyElementKey(reference: element) else {
            return
        }

        let isHidden = !show

        guard includeSubviews else {
            highlightViews[key]?.element.isHidden = isHidden
            return
        }

        element.underlyingView?.allSubviews.forEach {
            guard let highlightView = $0 as? HighlightView else { return }
            highlightView.isHidden = isHidden
        }
    }
}

// MARK: - LayerViewDelegate

extension ViewHierarchyCoordinator: LayerViewDelegate {
    func layerView(_ layerView: LayerViewProtocol, didSelect element: ViewHierarchyElementReference, withAction action: ViewHierarchyAction) {
        guard canPerform(action: action) else {
            delegate?.perform(action: action, with: element, from: layerView.sourceView)
            return
        }

        perform(action: action, with: element, from: layerView.sourceView)
    }
}
