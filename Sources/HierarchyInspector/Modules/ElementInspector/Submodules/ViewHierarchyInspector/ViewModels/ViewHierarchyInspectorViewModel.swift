//
//  ViewHierarchyInspectorViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ViewHierarchyInspectorViewModelProtocol {
    var title: String { get }
    
    var rootReference: ViewHierarchyReference { get }
    
    var numberOfRows: Int { get }
    
    func itemViewModel(for indexPath: IndexPath) -> ElementInspectorViewHierarchyPanelViewModelProtocol?
    
    /// Toggle if a container displays its subviews or hides them.
    /// - Parameter indexPath: row with
    /// - Returns: Actions related to affected index paths
    func toggleContainer(at indexPath: IndexPath) -> [ElementInspector.ViewHierarchyInspectorAction]
}

final class ViewHierarchyInspectorViewModel: NSObject {
    let rootReference: ViewHierarchyReference
    
    private(set) var childViewModels: [ElementInspector.ViewHierarchyPanelViewModel] {
        didSet {
            updateVisibleChildViews()
        }
    }
    
    private static func makeViewModels(
        reference: ViewHierarchyReference,
        parent: ElementInspector.ViewHierarchyPanelViewModel?,
        rootDepth: Int
    ) -> [ElementInspector.ViewHierarchyPanelViewModel] {
        let viewModel = ElementInspector.ViewHierarchyPanelViewModel(
            reference: reference,
            parent: parent,
            rootDepth: rootDepth,
            isCollapsed: reference.depth > rootDepth + 5
        )
        
        let childrenViewModels: [[ElementInspector.ViewHierarchyPanelViewModel]] = reference.children.map {
            makeViewModels(reference: $0, parent: viewModel, rootDepth: rootDepth)
        }
        
        return [viewModel] + childrenViewModels.flatMap { $0 }
    }
    
    private lazy var visibleChildViewModels: [ElementInspector.ViewHierarchyPanelViewModel] = []
    
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

extension ViewHierarchyInspectorViewModel: ViewHierarchyInspectorViewModelProtocol {
    var title: String {
        "More info"
    }
    
    var numberOfRows: Int {
        visibleChildViewModels.count
    }
    
    func itemViewModel(for indexPath: IndexPath) -> ElementInspectorViewHierarchyPanelViewModelProtocol? {
        let visibleChildViewModels = self.visibleChildViewModels
        
        guard indexPath.row < visibleChildViewModels.count else {
            return nil
        }
        
        return visibleChildViewModels[indexPath.row]
    }
    
    func toggleContainer(at indexPath: IndexPath) -> [ElementInspector.ViewHierarchyInspectorAction] {
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
        
        var actions = [ElementInspector.ViewHierarchyInspectorAction]()
        
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
