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

protocol ViewHierarchyCoordinatorDelegate: AnyObject {
    func viewHierarchyCoordinator(_ coordinator: ViewHierarchyCoordinator, didSelect reference: ViewHierarchyReference, from sourceView: HighlightView)
}

protocol ViewHierarchyCoordinatorDataSource: AnyObject {
    var rootView: UIView? { get }

    var viewHierarchyLayers: [Inspector.ViewHierarchyLayer] { get }

    var viewHierarchyColorScheme: Inspector.ViewHierarchyColorScheme { get }

    var elementLibraries: [InspectorElementLibraryProtocol] { get }
}

final class ViewHierarchyCoordinator: Coordinator {
    // MARK: - Properties

    weak var delegate: ViewHierarchyCoordinatorDelegate?

    weak var dataSource: ViewHierarchyCoordinatorDataSource?

    let operationQueue = OperationQueue.main

    private var cachedSnapshot: ViewHierarchySnapshot?

    var wireframeViews: [ViewHierarchyReference: WireframeView] = [:] {
        didSet {
            updateLayerViews(to: wireframeViews, from: oldValue)
        }
    }

    var highlightViews: [ViewHierarchyReference: HighlightView] = [:] {
        didSet {
            updateLayerViews(to: highlightViews, from: oldValue)
        }
    }

    var visibleReferences: [ViewHierarchyLayer: [ViewHierarchyReference]] = [:] {
        didSet {
            let layers = Set<ViewHierarchyLayer>(visibleReferences.keys)
            let oldLayers = Set<ViewHierarchyLayer>(oldValue.keys)
            let newLayers = layers.subtracting(oldLayers)
            let removedLayers = oldLayers.subtracting(layers)

            removeReferences(for: removedLayers, in: oldValue)

            guard let dataSource = dataSource else { return }

            addReferences(for: newLayers, with: dataSource.viewHierarchyColorScheme)
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

    func start() {
        cachedSnapshot = makeSnapshot()
    }

}

// MARK: - Internal Interface

extension ViewHierarchyCoordinator {

    func clearData() {
        cachedSnapshot = nil
        visibleReferences.removeAll()
        wireframeViews.removeAll()
        highlightViews.removeAll()
    }

    func currentSnapshot() -> ViewHierarchySnapshot? {
        if cachedSnapshot?.isValid == true { return cachedSnapshot }

        let snapshot = makeSnapshot()

        cachedSnapshot = snapshot

        return snapshot
    }

    func commandGroups() -> CommandGroups {
        var commands = CommandGroups()

        guard let snapshot = currentSnapshot() else { return commands }

        commands.append(availableLayerCommands(for: snapshot))

        commands.append(toggleAllLayersCommands(for: snapshot))

        return commands
    }

    private func makeSnapshot() -> ViewHierarchySnapshot? {
        guard
            let dataSource = dataSource,
            let viewHierarchy = dataSource.rootView
        else {
            return nil
        }

        return ViewHierarchySnapshot(
            availableLayers: dataSource.viewHierarchyLayers,
            elementLibraries: dataSource.elementLibraries,
            in: viewHierarchy
        )
    }
}

// MARK: - HighlightViewDelegate

extension ViewHierarchyCoordinator: HighlightViewDelegate {
    func highlightView(_ highlightView: HighlightView, didTapWith reference: ViewHierarchyReference) {
        delegate?.viewHierarchyCoordinator(self, didSelect: reference, from: highlightView)
    }
}
