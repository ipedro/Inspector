//
//  ViewHierarchyListViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListViewController: UIViewController {
    private lazy var viewCode = ViewHierarchyListViewCode().then {
        $0.tableView.dataSource = self
        $0.tableView.delegate   = self
    }
    
    private var viewModel: ViewHierarchyListViewModelProtocol!
    
    override func loadView() {
        view = viewCode
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize = viewCode.tableView.contentSize
    }
    
    static func create(viewModel: ViewHierarchyListViewModelProtocol) -> ViewHierarchyListViewController {
        let viewController = ViewHierarchyListViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
}

extension ViewHierarchyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ViewHierarchyListTableViewCodeCell.self, for: indexPath)
        cell.viewModel = viewModel.itemViewModel(for: indexPath)
        cell.isEvenRow = indexPath.row % 2 == 0
        
        return cell
    }
}

extension ViewHierarchyListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let results = viewModel.toggleContainer(at: indexPath)
        
        guard results.isEmpty == false else {
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? ViewHierarchyListTableViewCodeCell {
            cell.toggleCollapse(animated: true)
        }
        
        tableView.performBatchUpdates({
            
            results.forEach {
                switch $0 {
                case let .inserted(insertIndexPaths):
                    tableView.insertRows(at: insertIndexPaths, with: .top)
                    
                case let .deleted(deleteIndexPaths):
                    tableView.deleteRows(at: deleteIndexPaths, with: .top)
                }
            }
            
        },
        completion: { _ in
            
            UIView.animate(withDuration: 0.25) {
                
                tableView.indexPathsForVisibleRows?.forEach { indexPath in
                    guard let cell = tableView.cellForRow(at: indexPath) as? ViewHierarchyListTableViewCodeCell else {
                        return
                    }
                    
                    cell.isEvenRow = indexPath.row % 2 == 0
                }
                
            }
            
        })
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let text = viewModel.title(for: section) else {
//            return UIView().then {
//                $0.heightAnchor.constraint(equalToConstant: 0).isActive = true
//            }
//        }
//
//        return SectionHeader(.body, text: text)
//    }
    
}
