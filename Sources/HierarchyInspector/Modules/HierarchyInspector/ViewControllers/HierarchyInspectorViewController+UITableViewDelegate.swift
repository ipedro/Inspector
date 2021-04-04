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
            let headerView = headers[firstVisibleSection]
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        dequeueHeaderView(in: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Console.print(indexPath)
    }
    
}
