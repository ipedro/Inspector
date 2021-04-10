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
        viewModel.cellViewModelForRow(at: indexPath).isEnabled ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.heightForRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(HierarchyInspectorHeaderView.self)
        header.title = viewModel.titleForHeader(in: section)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: false) { [weak self] in
            guard
                let self = self,
                let viewHierarchyReference = self.viewModel?.selectRow(at: indexPath)
            else {
                return
            }
            
            self.delegate?.hierarchyInspectorViewController(self, didSelect: viewHierarchyReference)
        }
    }
    
}
