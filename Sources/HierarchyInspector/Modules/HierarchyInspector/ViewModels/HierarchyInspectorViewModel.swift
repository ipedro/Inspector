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

enum HierarchyInspectorCellViewModel {
    case layerAction(HierarchyInspectorLayerAcionCellViewModelProtocol)
    case snaphot(HierarchyInspectorSnapshotCellViewModelProtocol)
    
    var cellClassForCoder: AnyClass {
        switch self {
        case .layerAction:
            return HierarchyInspectorLayerActionCell.classForCoder()
            
        case .snaphot:
            return HierarchyInspectorSnapshotCell.classForCoder()
        }
    }
}

protocol HierarchyInspectorViewModelSectionProtocol {
    var numberOfSections: Int { get }
    
    var isEmpty: Bool { get }
    
    func numberOfRows(in section: Int) -> Int
    
    func titleForHeader(in section: Int) -> String?
    
    func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel
    
    func selectRow(at indexPath: IndexPath) -> ViewHierarchyReference?
    
    func isRowEnabled(at indexPath: IndexPath) -> Bool
    
    func loadData()
}

final class HierarchyInspectorViewModel {
    
    typealias ActionGroupsProvider = (() -> ActionGroups?)
    
    let actionGroupsViewModel: ActionGroupsViewModel
    
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
        actionGroupsProvider: @escaping ActionGroupsProvider,
        snapshot: ViewHierarchySnapshot
    ) {
        actionGroupsViewModel = ActionGroupsViewModel(actionGroupsProvider: actionGroupsProvider)
        snapshotViewModel = SnapshotViewModel(snapshot: snapshot)
    }
}

// MARK: - HierarchyInspectorViewModelProtocol

extension HierarchyInspectorViewModel: HierarchyInspectorViewModelProtocol {
    func isRowEnabled(at indexPath: IndexPath) -> Bool {
        switch isSearching {
        case true:
            return snapshotViewModel.isRowEnabled(at: indexPath)
            
        case false:
            return actionGroupsViewModel.isRowEnabled(at: indexPath)
        }
    }
    
    var isEmpty: Bool {
        switch isSearching {
        case true:
            return snapshotViewModel.isEmpty
            
        case false:
            return actionGroupsViewModel.isEmpty
        }
    }
    
    func loadData() {
        switch isSearching {
        case true:
            return snapshotViewModel.loadData()
            
        case false:
            return actionGroupsViewModel.loadData()
        }
    }
    
    func selectRow(at indexPath: IndexPath) -> ViewHierarchyReference? {
        switch isSearching {
        case true:
            return snapshotViewModel.selectRow(at: indexPath)
            
        case false:
            return actionGroupsViewModel.selectRow(at: indexPath)
        }
    }
    
    var numberOfSections: Int {
        switch isSearching {
        case true:
            return snapshotViewModel.numberOfSections
            
        case false:
            return actionGroupsViewModel.numberOfSections
        }
    }
    
    func numberOfRows(in section: Int) -> Int {
        switch isSearching {
        case true:
            return snapshotViewModel.numberOfRows(in: section)
            
        case false:
            return actionGroupsViewModel.numberOfRows(in: section)
        }
    }
    
    func titleForHeader(in section: Int) -> String? {
        switch isSearching {
        case true:
            return snapshotViewModel.titleForHeader(in: section)
            
        case false:
            return actionGroupsViewModel.titleForHeader(in: section)
        }
    }
    
    func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel {
        switch isSearching {
        case true:
            return snapshotViewModel.cellViewModelForRow(at: indexPath)
            
        case false:
            return actionGroupsViewModel.cellViewModelForRow(at: indexPath)
        }
    }
}

protocol TextElement: UIView {
    var content: String? { get }
}

extension UILabel: TextElement {
    var content: String? { text }
}

extension UITextView: TextElement {
    var content: String? { text }
}

extension UITextField: TextElement {
    var content: String? { text }
}
