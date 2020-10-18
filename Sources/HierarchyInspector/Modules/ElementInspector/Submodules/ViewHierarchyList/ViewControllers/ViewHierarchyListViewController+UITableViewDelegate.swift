//
//  ViewHierarchyListViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

// MARK: - UITableViewDelegate

extension ViewHierarchyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let itemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return false
        }
        
        return itemViewModel.isContainer == true || itemViewModel.showDisclosureIndicator
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let itemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return
        }
        
        self.delegate?.viewHierarchyListViewController(self, didSelectInfo: itemViewModel.reference, from: self.viewModel.rootReference)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let itemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return
        }
        
        guard itemViewModel.showDisclosureIndicator else {
            return toggleContainer(at: indexPath)
        }
        
        delegate?.viewHierarchyListViewController(self, didSegueTo: itemViewModel.reference, from: viewModel.rootReference)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard
            viewModel.shouldDisplayThumbnails,
            let cell = cell as? ViewHierarchyListTableViewCodeCell
        else {
            return
        }

        let thumbnailOperation = MainThreadAsyncOperation(name: "render thumb for row \(indexPath.row)") {
            cell.renderThumbnailImage()
        }

        delegate?.addOperationToQueue(thumbnailOperation)
    }
    
    private func toggleContainer(at indexPath: IndexPath) {
        let actions = viewModel.toggleContainer(at: indexPath)
        
        updateTableView(indexPath, with: actions)
    }
}

// MARK: - Helpers

private extension ViewHierarchyListViewController {
    
    func updateTableView(_ indexPath: IndexPath, with actions: [ViewHierarchyListAction]) {
        guard actions.isEmpty == false else {
            return
        }
        
        delegate?.suspendQueue(true)
        
        viewModel.shouldDisplayThumbnails = false
        
        let tableView = viewCode.tableView
        
        var insertedIndexPaths = [IndexPath]()
        
        if let cell = tableView.cellForRow(at: indexPath) as? ViewHierarchyListTableViewCodeCell {
            cell.toggleCollapse(animated: true)
        }
        
        tableView.performBatchUpdates({
            
            actions.forEach {
                switch $0 {
                case let .inserted(indexPaths):
                    insertedIndexPaths.append(contentsOf: indexPaths)
                    
                    tableView.insertRows(at: indexPaths, with: .top)
                    
                case let .deleted(indexPaths):
                    tableView.deleteRows(at: indexPaths, with: .top)
                }
            }
            
        },
        completion: { [weak self] _ in
            
            self?.updatePreferredContentSize()
            
            self?.updateVisibleRowsBackgroundColor { [weak self] _ in
            
                self?.viewModel.shouldDisplayThumbnails = true
                
                self?.delegate?.suspendQueue(false)
                
                insertedIndexPaths.forEach {
                    guard let cell = tableView.cellForRow(at: $0) as? ViewHierarchyListTableViewCodeCell else {
                        return
                    }
                    
                    let thumbnailOperation = MainThreadAsyncOperation(name: "render thumb for row \(indexPath.row)") {
                        cell.renderThumbnailImage()
                    }
                    
                    self?.delegate?.addOperationToQueue(thumbnailOperation)
                }
            }
            
        })
    }
    
    func updateVisibleRowsBackgroundColor(_ completion: ((Bool) -> Void)?) {
        UIView.animate(
            withDuration: ElementInspector.animationDuration,
            animations: { [weak self] in
            
                self?.viewCode.tableView.indexPathsForVisibleRows?.forEach { indexPath in
                    guard let cell = self?.viewCode.tableView.cellForRow(at: indexPath) as? ViewHierarchyListTableViewCodeCell else {
                        return
                    }
                    
                    cell.isEvenRow = indexPath.row % 2 == 0
                }
            
            },
            completion: completion
        )
    }
}
