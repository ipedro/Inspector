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

enum HierarchyInspectorCellViewModel {
    case action(HierarchyInspectorActionTableViewCellViewModelProtocol)
    case element(HierarchyInspectorReferenceSummaryCellViewModelProtocol)
}

protocol HierarchyInspectorViewModelProtocol: HierarchyInspectorSectionViewModelProtocol {
    var isSearching: Bool { get }
    var searchQuery: String? { get set }
}

protocol HierarchyInspectorSectionViewModelProtocol {
    var numberOfSections: Int { get }

    var isEmpty: Bool { get }

    var shouldAnimateKeyboard: Bool { get }

    func numberOfRows(in section: Int) -> Int

    func titleForHeader(in section: Int) -> String?

    func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel

    func selectRow(at indexPath: IndexPath) -> InspectorCommand?

    func isRowEnabled(at indexPath: IndexPath) -> Bool

    func loadData()
}

final class HierarchyInspectorViewModel {
    typealias CommandGroupsProvider = (() -> CommandGroups?)

    let commandGroupsViewModel: CommandGroupsViewModel

    let snapshotViewModel: SnapshotViewModel

    var isSearching: Bool {
        searchQuery.isNilOrEmpty == false
    }

    var searchQuery: String? {
        didSet {
            let trimmedQuery = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
            snapshotViewModel.searchQuery = trimmedQuery?.isEmpty == false ? trimmedQuery : nil
        }
    }

    init(
        commandGroupsProvider: @escaping CommandGroupsProvider,
        snapshot: ViewHierarchySnapshot
    ) {
        commandGroupsViewModel = CommandGroupsViewModel(commandGroupsProvider: commandGroupsProvider)
        snapshotViewModel = SnapshotViewModel(snapshot: snapshot)
    }
}

// MARK: - HierarchyInspectorViewModelProtocol

extension HierarchyInspectorViewModel: HierarchyInspectorViewModelProtocol {
    var shouldAnimateKeyboard: Bool {
        // swift ui handles keyboard affordances on it's own
        Inspector.manager.swiftUIhost == nil
    }

    func isRowEnabled(at indexPath: IndexPath) -> Bool {
        switch isSearching {
        case true:
            return snapshotViewModel.isRowEnabled(at: indexPath)

        case false:
            return commandGroupsViewModel.isRowEnabled(at: indexPath)
        }
    }

    var isEmpty: Bool {
        switch isSearching {
        case true:
            return snapshotViewModel.isEmpty

        case false:
            return commandGroupsViewModel.isEmpty
        }
    }

    func loadData() {
        switch isSearching {
        case true:
            return snapshotViewModel.loadData()

        case false:
            return commandGroupsViewModel.loadData()
        }
    }

    func selectRow(at indexPath: IndexPath) -> InspectorCommand? {
        switch isSearching {
        case true:
            return snapshotViewModel.selectRow(at: indexPath)

        case false:
            return commandGroupsViewModel.selectRow(at: indexPath)
        }
    }

    var numberOfSections: Int {
        switch isSearching {
        case true:
            return snapshotViewModel.numberOfSections

        case false:
            return commandGroupsViewModel.numberOfSections
        }
    }

    func numberOfRows(in section: Int) -> Int {
        switch isSearching {
        case true:
            return snapshotViewModel.numberOfRows(in: section)

        case false:
            return commandGroupsViewModel.numberOfRows(in: section)
        }
    }

    func titleForHeader(in section: Int) -> String? {
        switch isSearching {
        case true:
            return snapshotViewModel.titleForHeader(in: section)

        case false:
            return commandGroupsViewModel.titleForHeader(in: section)
        }
    }

    func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel {
        switch isSearching {
        case true:
            return snapshotViewModel.cellViewModelForRow(at: indexPath)

        case false:
            return commandGroupsViewModel.cellViewModelForRow(at: indexPath)
        }
    }
}
