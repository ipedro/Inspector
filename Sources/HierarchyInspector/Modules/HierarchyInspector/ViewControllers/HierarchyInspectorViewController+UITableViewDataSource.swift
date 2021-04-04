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
        let cell = tableView.dequeueReusableCell(HierarchyInspectorTableViewCell.self, for: indexPath)
        cell.textLabel?.text = viewModel.titleForRow(at: indexPath)
        cell.directionalLayoutMargins = .allMargins(ElementInspector.appearance.horizontalMargins)
        
        return cell
    }
}
