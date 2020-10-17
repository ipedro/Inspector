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
        
        delegate?.viewHierarchyListViewController(self, didSelectInfo: itemViewModel.reference, from: viewModel.rootReference)
        
        viewModel.clearAllCachedThumbnails()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ViewHierarchyListTableViewCodeCell else {
            return
        }
        
        guard let viewModel = cell.viewModel, viewModel.hasCachedThumbnailView == false else {
            Console.print("cell", indexPath, "using cached view")
            return cell.renderThumbnailImage()
        }
        
        let delayInMilliseconds: Int = {
            
            let uncachedVisibleRows = tableView.indexPathsForVisibleRows?.filter {
                self.viewModel.itemViewModel(for: $0)?.hasCachedThumbnailView == false
            }
            
            let itemDelay = 300
            
            guard let firstUncachedIndexPath = uncachedVisibleRows?.first else { return itemDelay }
            
            return itemDelay * (indexPath.row - firstUncachedIndexPath.row + 1)
        }()
        
        Console.print("cell \(indexPath)", "delay: \(delayInMilliseconds)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayInMilliseconds)) {
            cell.renderThumbnailImage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let itemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return
        }

        if itemViewModel.showDisclosureIndicator {
            
            delegate?.viewHierarchyListViewController(
                self,
                didSegueTo: itemViewModel.reference,
                from: viewModel.rootReference
            )
            
            viewModel.clearAllCachedThumbnails()
            return
        }
        
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
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
        
        let tableView = viewCode.tableView
        
        if let cell = tableView.cellForRow(at: indexPath) as? ViewHierarchyListTableViewCodeCell {
            cell.toggleCollapse(animated: true)
        }
        
        tableView.performBatchUpdates({
            
            actions.forEach {
                switch $0 {
                case let .inserted(insertIndexPaths):
                    tableView.insertRows(at: insertIndexPaths, with: .top)
                    
                case let .deleted(deleteIndexPaths):
                    tableView.deleteRows(at: deleteIndexPaths, with: .top)
                }
            }
            
        },
        completion: { [weak self] _ in
            
            UIView.animate(withDuration: 0.25) {
                
                tableView.indexPathsForVisibleRows?.forEach { indexPath in
                    guard let cell = tableView.cellForRow(at: indexPath) as? ViewHierarchyListTableViewCodeCell else {
                        return
                    }
                    
                    cell.isEvenRow = indexPath.row % 2 == 0
                }
                
            }
            
            self?.updatePreferredContentSize()
            
        })
    }
}
