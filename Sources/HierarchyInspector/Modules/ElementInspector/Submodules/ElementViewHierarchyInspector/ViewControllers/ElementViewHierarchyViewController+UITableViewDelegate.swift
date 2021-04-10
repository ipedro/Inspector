//
//  ElementViewHierarchyViewController+UITableViewDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

// MARK: - UITableViewDelegate

extension ElementViewHierarchyViewController: UITableViewDelegate {
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
        
        guard let selectedItemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return
        }
        
        guard selectedItemViewModel.showDisclosureIndicator else {
            return toggleContainer(at: indexPath)
        }
        
        delegate?.viewHierarchyListViewController(self, didSegueTo: selectedItemViewModel.reference, from: viewModel.rootReference)
    }
    
    private func toggleContainer(at indexPath: IndexPath) {
        let actions = viewModel.toggleContainer(at: indexPath)
        
        updateTableView(indexPath, with: actions)
    }
}

// MARK: - Helpers

private extension ElementViewHierarchyViewController {
    
    func updateTableView(_ indexPath: IndexPath, with actions: [ElementInspector.ViewHierarchyInspectorAction]) {
        guard actions.isEmpty == false else {
            return
        }
        
        let tableView = viewCode.tableView
        
        var insertedIndexPaths = [IndexPath]()
        
        if let cell = tableView.cellForRow(at: indexPath) as? ElementViewHierarchyInspectorTableViewCodeCell {
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
            guard let self = self else {
                return
            }
            
            self.updatePreferredContentSize()
            
            self.updateVisibleRowsBackgroundColor()
            
        })
    }
    
    func updateVisibleRowsBackgroundColor(_ completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: ElementInspector.configuration.animationDuration,
            animations: { [weak self] in
            
                self?.viewCode.tableView.indexPathsForVisibleRows?.forEach { indexPath in
                    guard let cell = self?.viewCode.tableView.cellForRow(at: indexPath) as? ElementViewHierarchyInspectorTableViewCodeCell else {
                        return
                    }
                    
                    cell.isEvenRow = indexPath.row % 2 == 0
                }
            
            },
            completion: completion
        )
    }
    
}
