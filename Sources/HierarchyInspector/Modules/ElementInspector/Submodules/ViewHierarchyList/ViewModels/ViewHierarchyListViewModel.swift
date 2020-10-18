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
    
    var rootReference: ViewHierarchyReference { get }
    
    var numberOfRows: Int { get }
    
    var shouldDisplayThumbnails: Bool { get set }
    
    func title(for section: Int) -> String?
    
    func itemViewModel(for indexPath: IndexPath) -> ViewHierarchyListItemViewModelProtocol?
    
    /// Toggle if a container displays its subviews or hides them.
    /// - Parameter indexPath: row with
    /// - Returns: Actions related to affected index paths
    func toggleContainer(at indexPath: IndexPath) -> [ViewHierarchyListAction]
    
    func clearAllCachedThumbnails()
}

final class ViewHierarchyListViewModel: NSObject {
    let rootReference: ViewHierarchyReference
    
    var shouldDisplayThumbnails: Bool = false
    
    private(set) var childViewModels: [ViewHierarchyListItemViewModel] {
        didSet {
            updateVisibleChildViews()
        }
    }
    
    private static func makeViewModels(
        reference: ViewHierarchyReference,
        parent: ViewHierarchyListItemViewModel?,
        rootDepth: Int
    ) -> [ViewHierarchyListItemViewModel] {
        let viewModel = ViewHierarchyListItemViewModel(
            reference: reference,
            parent: parent,
            rootDepth: rootDepth,
            isCollapsed: reference.depth > rootDepth + 1
        )
        
        let childrenViewModels: [[ViewHierarchyListItemViewModel]] = reference.children.map {
            makeViewModels(reference: $0, parent: viewModel, rootDepth: rootDepth)
        }
        
        return [viewModel] + childrenViewModels.flatMap { $0 }
    }
    
    private lazy var visibleChildViewModels: [ViewHierarchyListItemViewModel] = []
    
    init(reference: ViewHierarchyReference) {
        rootReference = reference
        
        childViewModels = Self.makeViewModels(
            reference: rootReference,
            parent: nil,
            rootDepth: rootReference.depth
        )
        
        super.init()
        
        updateVisibleChildViews()
    }
    
    func clearAllCachedThumbnails() {
        childViewModels.forEach { $0.cachedReferenceThumbnail = nil}
    }
}

extension ViewHierarchyListViewModel: ViewHierarchyListViewModelProtocol {
    
    var title: String {
        "More info"
    }
    
    func title(for section: Int) -> String? {
        nil //"View hierarchy"
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
        
        updateVisibleChildViews()
        
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
    
    private func updateVisibleChildViews() {
        visibleChildViewModels = childViewModels.filter { $0.isHidden == false }
    }
}
