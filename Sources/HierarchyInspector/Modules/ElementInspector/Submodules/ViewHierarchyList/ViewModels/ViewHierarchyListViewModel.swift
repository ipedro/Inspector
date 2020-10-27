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

protocol ViewHierarchyListViewModelDelegate: AnyObject {
    func viewHierarchyListViewModelDidLoad(_ viewModel: ViewHierarchyListViewModelProtocol)
}

protocol ViewHierarchyListViewModelProtocol {
    var delegate: ViewHierarchyListViewModelDelegate? { get set }
    
    var title: String { get }
    
    var rootReference: ViewHierarchyReference { get }
    
    var numberOfRows: Int { get }
    
    func itemViewModel(for indexPath: IndexPath) -> ViewHierarchyListItemViewModelProtocol?
    
    /// Toggle if a container displays its subviews or hides them.
    /// - Parameter indexPath: row with
    /// - Returns: Actions related to affected index paths
    func toggleContainer(at indexPath: IndexPath) -> [ViewHierarchyListAction]
    
    func clearCachedThumbnail(for indexPath: IndexPath)
    
    func loadOperations() -> [MainThreadOperation]
}

final class ViewHierarchyListViewModel: NSObject {
    var delegate: ViewHierarchyListViewModelDelegate?
    
    let rootReference: ViewHierarchyReference
    
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
}

extension ViewHierarchyListViewModel: ViewHierarchyListViewModelProtocol {
    func loadOperations() -> [MainThreadOperation] {
        var operations = childViewModels.enumerated().map { row, childViewModel -> MainThreadOperation in
            
            let operation = MainThreadOperation(name: childViewModel.title) {
                childViewModel.loadThumbnail()
            }
            
            operation.completionBlock = {
                Console.print(#function, "Loaded thumbnail for row \(row)")
            }
            
            return operation
        }
        
        let delegateOperation = MainThreadOperation(name: "delegate") { [weak self] in
            guard let self = self else {
                return
            }
            
            self.delegate?.viewHierarchyListViewModelDidLoad(self)
        }
        
        operations.append(delegateOperation)
        
        return operations
    }
    
    var title: String {
        "More info"
    }
    
    var numberOfRows: Int {
        visibleChildViewModels.count
    }
    
    func clearCachedThumbnail(for indexPath: IndexPath) {
        guard let selectedItemViewModel = itemViewModel(for: indexPath) else {
            return
        }
        
        for row in indexPath.row...numberOfRows {
            
            guard
                let rowViewModel = itemViewModel(for: IndexPath(row: row, section: .zero)),
                rowViewModel.relativeDepth > selectedItemViewModel.relativeDepth || rowViewModel === selectedItemViewModel
            else {
                return
            }
            
            rowViewModel.clearCachedThumbnail()
        }
        
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
