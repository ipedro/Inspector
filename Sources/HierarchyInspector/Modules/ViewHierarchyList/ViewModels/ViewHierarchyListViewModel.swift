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
}

protocol ViewHierarchyListViewModelProtocol {
    var title: String { get }
    
    var numberOfRows: Int { get }
    
    func itemViewModel(for indexPath: IndexPath) -> ViewHierarchyListItemViewModelProtocol?
    
    /// Toggle if a container displays its subviews or hides them.
    /// - Parameter indexPath: row with
    /// - Returns: Affected index paths
    func toggleContainer(at indexPath: IndexPath) -> ViewHierarchyListAction?
}

final class ViewHierarchyListViewModel: NSObject {
    let rootReference: ViewHierarchyReference
    
    private(set) lazy var childViewModels: [ViewHierarchyListItemViewModelProtocol] = {
        var array = [ViewHierarchyListItemViewModel(reference: rootReference)]
        
        rootReference.flattenedViewHierarchy.forEach {
            array.append(ViewHierarchyListItemViewModel(reference: $0))
        }
        
        return array
    }()
    
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
    
    
    func toggleContainer(at indexPath: IndexPath) -> ViewHierarchyListAction? {
        guard indexPath.row < visibleChildViewModels.count else {
            return .none
        }
        
        let container = visibleChildViewModels[indexPath.row]
        
        let index: Int? = childViewModels.firstIndex { $0 === container }
        
        guard
            let existingContainerRow = index,
            container.isContainer
        else {
            return .none
        }
        
        let newCollapseState = !container.isCollapsed
        
        var count = 0
        
        for (row, node) in childViewModels.enumerated() where row > existingContainerRow {
            guard node.depth > container.depth else {
                break
            }
            
            if node.isHidden != newCollapseState {
                node.isHidden = newCollapseState
                node.isCollapsed = false
                count += 1
            }
        }
        
        guard count > 0 else {
            return .none
        }
        
        container.isCollapsed = newCollapseState
        
        visibleChildViewModels = childViewModels.filter { $0.isHidden == false }
        
        let newIndex: Int? = visibleChildViewModels.firstIndex { $0 === container }
        
        guard let newContainerRow = newIndex else {
            return .none
        }
        
        var indexPaths = [IndexPath]()
        
        for n in 1 ... count {
            let row = newContainerRow + n
            
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        
        switch container.isCollapsed {
        case true:
            return .deleted(indexPaths)
        
        case false:
            return .inserted(indexPaths)
        }
    }
    
}
