//
//  ViewHierarchyListViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

// MARK: - UITableViewDataSourcePrefetching

extension ViewHierarchyListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            
            guard let viewModel = viewModel.itemViewModel(for: indexPath), viewModel.hasCachedThumbnailView == false else {
                return
            }
            
            #warning("migrate to operation queue")
            let delayInMilliseconds: Int = {
                
                let uncachedVisibleRows = tableView.indexPathsForVisibleRows?.filter {
                    self.viewModel.itemViewModel(for: $0)?.hasCachedThumbnailView == false
                }
                
                let itemDelay = 300
                
                guard let firstUncachedIndexPath = uncachedVisibleRows?.first else { return itemDelay }
                
                return itemDelay * (indexPath.row - firstUncachedIndexPath.row + 1)
            }()
            
            Console.print("prefetch cell \(indexPath)", "delay: \(delayInMilliseconds)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayInMilliseconds)) {
                _ = viewModel.thumbnailView
            }
            
        }
    }
}
