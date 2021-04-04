//
//  HierarchyInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.04.21.
//

import UIKit

protocol HierarchyInspectorViewModelProtocol: HierarchyInspectorViewModelSectionProtocol {
    var isSearching: Bool { get }
}

protocol HierarchyInspectorViewModelSectionProtocol {
    var numberOfSections: Int { get }
    
    func numberOfRows(in section: Int) -> Int
    
    func titleForHeader(in section: Int) -> String?
    
    func titleForRow(at indexPath: IndexPath) -> String
}

final class HierarchyInspectorViewModel {
    
    let layerActionsViewModel: LayerActionsViewModel
    let snapshotViewModel: SnapshotViewModel
    
    var isSearching: Bool = false
    
    init(
        layerActionGroups: ActionGroups,
        snapshot: ViewHierarchySnapshot
    ) {
        layerActionsViewModel = LayerActionsViewModel(layerActionGroups: layerActionGroups)
        snapshotViewModel = SnapshotViewModel(snapshot: snapshot)
    }
}

// MARK: - HierarchyInspectorViewModelProtocol

extension HierarchyInspectorViewModel: HierarchyInspectorViewModelProtocol {
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
        let layerActionGroups: ActionGroups
        
        init(layerActionGroups: ActionGroups) {
            self.layerActionGroups = layerActionGroups
        }
        
        var numberOfSections: Int {
            layerActionGroups.count
        }
        
        func numberOfRows(in section: Int) -> Int {
            layerActionGroups[section].actions.count
        }
        
        func titleForHeader(in section: Int) -> String? {
            layerActionGroups[section].displayName
        }
        
        func titleForRow(at indexPath: IndexPath) -> String {
            layerActionGroups[indexPath.section].actions[indexPath.row].title
        }
    }
}

extension HierarchyInspectorViewModel {
    final class SnapshotViewModel: HierarchyInspectorViewModelSectionProtocol {
        let numberOfSections = 1
        
        let snapshot: ViewHierarchySnapshot
        
        init(snapshot: ViewHierarchySnapshot) {
            self.snapshot = snapshot
        }
        
        func numberOfRows(in section: Int) -> Int {
            .zero
        }
        
        func titleForHeader(in section: Int) -> String? {
            fatalError()
        }
        
        func titleForRow(at indexPath: IndexPath) -> String {
            fatalError()
        }
    }
}
