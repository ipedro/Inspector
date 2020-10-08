//
//  ViewHierarchyListViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

enum ViewHierarchyListAction {
    case inserted([IndexPath])
    case deleted([IndexPath])
    
    var lastIndexPath: IndexPath? {
        switch self {
            case let .inserted(indexPaths),
                 let .deleted(indexPaths):
                return indexPaths.last
        }
    }
}

protocol ViewHierarchyListViewModelProtocol {
    var title: String { get }
    
    var numberOfRows: Int { get }
    
    func itemViewModel(for indexPath: IndexPath) -> ViewHierarchyListItemViewModelProtocol?
    
    /// Toggle if a container displays its subviews or hides them.
    /// - Parameter indexPath: row with
    /// - Returns: Affected index paths
    func toggleContainer(at indexPath: IndexPath) -> [ViewHierarchyListAction]
}

final class ViewHierarchyListViewModel: NSObject {
    let rootReference: ViewHierarchyReference
    
    private(set) lazy var childViewModels: [ViewHierarchyListItemViewModel] = {
        let rootViewModel = ViewHierarchyListItemViewModel(reference: rootReference, rootDepth: rootReference.depth)
        
        var array = [rootViewModel]
        
        let children = rootReference.children.map { makeViewModels(reference: $0, parent: rootViewModel) }
        
        array.append(contentsOf: children.flatMap { $0 })
        
        return array
    }()
    
    func makeViewModels(reference: ViewHierarchyReference, parent: ViewHierarchyListItemViewModel?) -> [ViewHierarchyListItemViewModel] {
        let viewModel = ViewHierarchyListItemViewModel(
            reference: reference,
            parent: parent,
            rootDepth: rootReference.depth
        )
        
        let childrenViewModels: [[ViewHierarchyListItemViewModel]] = reference.children.map {
            makeViewModels(reference: $0, parent: viewModel)
        }
        
        return [viewModel] + childrenViewModels.flatMap { $0 }
    }
    
    private lazy var visibleChildViewModels = childViewModels
    
    init(reference: ViewHierarchyReference) {
        self.rootReference = reference
    }
}

extension ViewHierarchyListViewModel: ViewHierarchyListViewModelProtocol {
    var title: String {
        "More info"
    }
    
    var numberOfRows: Int {
        visibleChildViewModels.count
    }
    
    func itemViewModel(for indexPath: IndexPath) -> ViewHierarchyListItemViewModelProtocol? {
        let visibleChildViewModels = self.visibleChildViewModels
        
        guard indexPath.row < visibleChildViewModels.count else {
            return nil
        }
        
        return visibleChildViewModels[indexPath.row]
    }
    
    func toggleContainer(at indexPath: IndexPath) -> [ViewHierarchyListAction] {
        guard indexPath.row < visibleChildViewModels.count else {
            return []
        }
        
        let container = visibleChildViewModels[indexPath.row]
        
        guard container.isContainer else {
            return []
        }
        
        container.isCollapsed.toggle()
        
        let oldVisibleChildren = visibleChildViewModels
        
        visibleChildViewModels = childViewModels.filter { $0.isHidden == false }
        
        let addedChildren = Set(visibleChildViewModels).subtracting(oldVisibleChildren)
        
        let deletedChildren = Set(oldVisibleChildren).subtracting(visibleChildViewModels)
        
        var deletedIndexPaths = [IndexPath]()
        
        var insertedIndexPaths = [IndexPath]()
        
        for child in deletedChildren {
            guard let row = oldVisibleChildren.firstIndex(of: child) else {
                continue
            }
            
            deletedIndexPaths.append(IndexPath(row: row, section: 0))
        }
        
        for child in addedChildren {
            guard let row = visibleChildViewModels.firstIndex(of: child) else {
                continue
            }
            
            insertedIndexPaths.append(IndexPath(row: row, section: 0))
        }
        
        var actions = [ViewHierarchyListAction]()
        
        if insertedIndexPaths.isEmpty == false {
            actions.append(.inserted(insertedIndexPaths))
        }
        
        if deletedIndexPaths.isEmpty == false {
            actions.append(.deleted(deletedIndexPaths))
        }
        
        return actions
    }
}
