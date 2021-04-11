//
//  HierarchyInspectorViewController+UITableViewDelegate.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.04.21.
//

import UIKit

extension HierarchyInspectorViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            let firstVisibleSection = viewCode.tableView.indexPathsForVisibleRows?.first?.section,
            let headerView = viewCode.tableView.headerView(forSection: firstVisibleSection)
        else {
            return
        }
        
        for cell in viewCode.tableView.visibleCells {
            guard let cell = cell as? HierarchyInspectorTableViewCell else {
                return
            }
            
            let headerHeight: CGFloat = headerView.frame.height
            
            let hiddenFrameHeight = scrollView.contentOffset.y + headerHeight - cell.frame.origin.y
            
            if hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height {
                cell.maskCellFromTop(margin: hiddenFrameHeight)
            }
            else {
                break
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        viewModel.isRowEnabled(at: indexPath) ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(HierarchyInspectorHeaderView.self)
        header.title = viewModel.titleForHeader(in: section)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.hierarchyInspectorViewController(self, didSelect: viewModel?.selectRow(at: indexPath))
    }
    
}
