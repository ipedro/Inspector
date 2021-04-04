//
//  HierarchyInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

protocol HierarchyInspectorViewModelProtocol: HierarchyInspectorViewModelSectionProtocol {
    var isSearching: Bool { get }
    
    var searchQuery: String? { get set }
}

protocol HierarchyInspectorViewModelSectionProtocol {
    var numberOfSections: Int { get }
    
    var isEmpty: Bool { get }
    
    func numberOfRows(in section: Int) -> Int
    
    func titleForHeader(in section: Int) -> String?
    
    func titleForRow(at indexPath: IndexPath) -> String
    
    func selectRow(at indexPath: IndexPath)
    
    func loadData()
}

final class HierarchyInspectorViewModel {
    
    let layerActionsViewModel: LayerActionsViewModel
    
    let snapshotViewModel: SnapshotViewModel
    
    var isSearching: Bool {
        searchQuery.isNilOrEmpty == false
    }
    
    var searchQuery: String? {
        didSet {
            snapshotViewModel.searchQuery = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    init(
        layerActionGroupsProvider: @escaping (() -> ActionGroups),
        snapshot: ViewHierarchySnapshot
    ) {
        layerActionsViewModel = LayerActionsViewModel(layerActionGroupsProvider: layerActionGroupsProvider)
        snapshotViewModel = SnapshotViewModel(snapshot: snapshot)
    }
}

// MARK: - HierarchyInspectorViewModelProtocol

extension HierarchyInspectorViewModel: HierarchyInspectorViewModelProtocol {
    var isEmpty: Bool {
        switch isSearching {
        case true:
            return snapshotViewModel.isEmpty
            
        case false:
            return layerActionsViewModel.isEmpty
        }
    }
    
    func loadData() {
        switch isSearching {
        case true:
            return snapshotViewModel.loadData()
            
        case false:
            return layerActionsViewModel.loadData()
        }
    }
    
    func selectRow(at indexPath: IndexPath) {
        switch isSearching {
        case true:
            return snapshotViewModel.selectRow(at: indexPath)
            
        case false:
            return layerActionsViewModel.selectRow(at: indexPath)
        }
    }
    
    var numberOfSections: Int {
        switch isSearching {
        case true:
            return snapshotViewModel.numberOfSections
            
        case false:
            return layerActionsViewModel.numberOfSections
        }
    }
    
    func numberOfRows(in section: Int) -> Int {
        switch isSearching {
        case true:
            return snapshotViewModel.numberOfRows(in: section)
            
        case false:
            return layerActionsViewModel.numberOfRows(in: section)
        }
    }
    
    func titleForHeader(in section: Int) -> String? {
        switch isSearching {
        case true:
            return snapshotViewModel.titleForHeader(in: section)
            
        case false:
            return layerActionsViewModel.titleForHeader(in: section)
        }
    }
    
    func titleForRow(at indexPath: IndexPath) -> String {
        switch isSearching {
        case true:
            return snapshotViewModel.titleForRow(at: indexPath)
            
        case false:
            return layerActionsViewModel.titleForRow(at: indexPath)
        }
    }
}

extension HierarchyInspectorViewModel {
    final class LayerActionsViewModel: HierarchyInspectorViewModelSectionProtocol {
        private(set) lazy var layerActionGroups = ActionGroups()
        
        let layerActionGroupsProvider: () -> ActionGroups
        
        init(layerActionGroupsProvider: @escaping () -> ActionGroups) {
            self.layerActionGroupsProvider = layerActionGroupsProvider
        }
        
        var isEmpty: Bool {
            var totalActionCount = 0
            
            for group in layerActionGroups {
                totalActionCount += group.actions.count
            }
            
            return totalActionCount == 0
        }
        
        func loadData() {
            layerActionGroups = layerActionGroupsProvider()
        }
        
        func selectRow(at indexPath: IndexPath) {
            action(at: indexPath).closure?()
        }
        
        var numberOfSections: Int {
            layerActionGroups.count
        }
        
        func numberOfRows(in section: Int) -> Int {
            actionGroup(in: section).actions.count
        }
        
        func titleForHeader(in section: Int) -> String? {
            actionGroup(in: section).title
        }
        
        func titleForRow(at indexPath: IndexPath) -> String {
            action(at: indexPath).title
        }
        
        private func actionGroup(in section: Int) -> ActionGroup {
            layerActionGroups[section]
        }
        
        private func action(at indexPath: IndexPath) -> Action {
            actionGroup(in: indexPath.section).actions[indexPath.row]
        }
    }
}

extension HierarchyInspectorViewModel {
    final class SnapshotViewModel: HierarchyInspectorViewModelSectionProtocol {
        var searchQuery: String? {
            didSet {
                loadData()
            }
        }
        
        let snapshot: ViewHierarchySnapshot
        
        private var searchResults = [ViewHierarchyReference]() {
            didSet {
                Console.print("search results: \(searchResults.count)")
            }
        }
        
        init(snapshot: ViewHierarchySnapshot) {
            self.snapshot = snapshot
        }
        
        var isEmpty: Bool { searchResults.isEmpty }
        
        let numberOfSections = 1
        
        func selectRow(at indexPath: IndexPath) {
            Console.print(indexPath)
        }
        
        func numberOfRows(in section: Int) -> Int {
            searchResults.count
        }
        
        func titleForHeader(in section: Int) -> String? {
            "Search Results in \(snapshot.viewHierarchy.elementName)"
        }
        
        func titleForRow(at indexPath: IndexPath) -> String {
            let result = searchResults[indexPath.row]
            
            let start: String = {
                switch result.depth {
                case .zero:
                    return "┬"
                    
                default:
                    return String(repeating: " |", count: result.depth)
                }
            }()
            
            return "\(start)   \(result.elementName)"
        }
        
        func loadData() {
            guard let searchQuery = searchQuery else {
                searchResults = []
                return
            }
            
            let flattenedViewHierarchy = [snapshot.viewHierarchy] + snapshot.flattenedViewHierarchy
            
            searchResults = flattenedViewHierarchy.filter {
                $0.elementName.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
    }
}
