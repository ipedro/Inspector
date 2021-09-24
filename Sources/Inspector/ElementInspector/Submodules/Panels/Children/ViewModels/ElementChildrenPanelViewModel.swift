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

protocol ElementChildrenPanelViewModelProtocol {
    var title: String { get }

    var rootReference: ViewHierarchyReference { get }

    var numberOfRows: Int { get }

    func shouldHighlightItem(at indexPath: IndexPath) -> Bool

    func reloadIcons()

    func itemViewModel(at indexPath: IndexPath) -> ElementChildrenPanelItemViewModelProtocol?

    func image(for reference: ViewHierarchyReference) -> UIImage?

    /// Toggle if a container displays its subviews or hides them.
    /// - Parameter indexPath: index path
    /// - Returns: Actions related to affected index paths
    func toggleContainer(at indexPath: IndexPath) -> [ElementInspector.ElementChildrenPanelAction]

    func indexPath(for item: ElementChildrenPanelItemViewModelProtocol?) -> IndexPath?
}

final class ElementChildrenPanelViewModel: NSObject {
    let rootReference: ViewHierarchyReference

    private(set) var children: [ItemViewModel] {
        didSet {
            updateVisibleChildren()
        }
    }

    private static func makeViewModels(
        reference: ViewHierarchyReference,
        parent: ItemViewModel?,
        snapshot: ViewHierarchySnapshot,
        rootDepth: Int
    ) -> [ItemViewModel] {
        let viewModel = ItemViewModel(
            reference: reference,
            parent: parent,
            rootDepth: rootDepth,
            thumbnailImage: snapshot.elementLibraries.icon(for: reference.rootView),
            isCollapsed: reference.depth >= rootDepth
        )

        let childrenViewModels: [ItemViewModel] = reference.children.flatMap { childReference in
            makeViewModels(
                reference: childReference,
                parent: viewModel,
                snapshot: snapshot,
                rootDepth: rootDepth
            )
        }

        return [viewModel] + childrenViewModels
    }

    private lazy var visibleChildren: [ItemViewModel] = []

    let snapshot: ViewHierarchySnapshot

    init(reference: ViewHierarchyReference, snapshot: ViewHierarchySnapshot) {
        rootReference = reference
        self.snapshot = snapshot

        let viewModelsIncludingRoot = Self.makeViewModels(
            reference: rootReference,
            parent: nil,
            snapshot: snapshot,
            rootDepth: rootReference.depth + 1 // account for removal of root reference
        )

        let children = Array(viewModelsIncludingRoot.dropFirst())

        self.children = children

        super.init()

        updateVisibleChildren()
    }
}

extension ElementChildrenPanelViewModel: ElementChildrenPanelViewModelProtocol {
    func shouldHighlightItem(at indexPath: IndexPath) -> Bool { true }

    var title: String { "More info" }

    var numberOfRows: Int { visibleChildren.count }

    func reloadIcons() {
        children.forEach { child in
            child.iconImage = snapshot.elementLibraries.icon(for: child.reference.rootView)
        }
    }

    func image(for reference: ViewHierarchyReference) -> UIImage? {
        snapshot.elementLibraries.icon(for: reference.rootView)
    }

    func itemViewModel(at indexPath: IndexPath) -> ElementChildrenPanelItemViewModelProtocol? {
        guard indexPath.row < visibleChildren.count else { return nil }

        return visibleChildren[indexPath.row]
    }

    func indexPath(for item: ElementChildrenPanelItemViewModelProtocol?) -> IndexPath? {
        guard
            let item = item as? ItemViewModel,
            let row = visibleChildren.firstIndex(of: item)
        else {
            return nil
        }

        return IndexPath(row: row, section: .zero)
    }

    func toggleContainer(at indexPath: IndexPath) -> [ElementInspector.ElementChildrenPanelAction] {
        guard indexPath.row < visibleChildren.count else { return [] }

        let container = visibleChildren[indexPath.row]

        guard container.isContainer else { return [] }

        container.isCollapsed.toggle()

        let oldVisibleChildren = visibleChildren

        updateVisibleChildren()

        let addedChildren = Set(visibleChildren).subtracting(oldVisibleChildren)

        let deletedChildren = Set(oldVisibleChildren).subtracting(visibleChildren)

        var deletedIndexPaths = [IndexPath]()

        var insertedIndexPaths = [IndexPath]()

        for child in deletedChildren {
            guard let row = oldVisibleChildren.firstIndex(of: child) else { continue }

            deletedIndexPaths.append(IndexPath(row: row, section: 0))
        }

        for child in addedChildren {
            guard let row = visibleChildren.firstIndex(of: child) else { continue }

            insertedIndexPaths.append(IndexPath(row: row, section: 0))
        }

        var actions = [ElementInspector.ElementChildrenPanelAction]()

        if insertedIndexPaths.isEmpty == false {
            actions.append(.inserted(insertedIndexPaths))
        }

        if deletedIndexPaths.isEmpty == false {
            actions.append(.deleted(deletedIndexPaths))
        }

        return actions
    }

    private func updateVisibleChildren() {
        visibleChildren = children.filter { $0.isHidden == false }
    }
}
