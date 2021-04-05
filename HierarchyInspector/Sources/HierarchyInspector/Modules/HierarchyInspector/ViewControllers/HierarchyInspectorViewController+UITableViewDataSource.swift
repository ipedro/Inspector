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
        let cellViewModel = viewModel.cellViewModelForRow(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(HierarchyInspectorTableViewCell.self, for: indexPath)
        cell.textLabel?.text = cellViewModel.title
        cell.textLabel?.font = cellViewModel.titleFont
        cell.detailTextLabel?.text = cellViewModel.subtitle
        cell.imageView?.image = cellViewModel.image
        cell.directionalLayoutMargins = .margins(
            top: ElementInspector.appearance.horizontalMargins,
            leading: ElementInspector.appearance.horizontalMargins + CGFloat(cellViewModel.depth * 10),
            bottom: ElementInspector.appearance.horizontalMargins,
            trailing: ElementInspector.appearance.horizontalMargins
        )
        
        return cell
    }
}
