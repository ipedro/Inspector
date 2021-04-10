//
//  HierarchyInspectorViewController+UITableViewDataSource.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.04.21.
//

import UIKit

extension HierarchyInspectorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            switch viewModel.cellViewModelForRow(at: indexPath) {
            case let .layerAction(cellViewModel):
                let cell = tableView.dequeueReusableCell(HierarchyInspectorLayerActionCell.self, for: indexPath)
                cell.viewModel = cellViewModel
                return cell
                
            case let .snaphot(cellViewModel):
                let cell = tableView.dequeueReusableCell(HierarchyInspectorSnapshotCell.self, for: indexPath)
                cell.viewModel = cellViewModel
                return cell
            }
            
        }()
        
        cell.isSelected = tableView.indexPathForSelectedRow == indexPath
        return cell
    }
}
