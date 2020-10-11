//
//  ViewHierarchyListViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ViewHierarchyListViewControllerDelegate: AnyObject {
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSelect reference: ViewHierarchyReference)
}

final class ViewHierarchyListViewController: UIViewController {
    weak var delegate: ViewHierarchyListViewControllerDelegate?
    
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
        
        viewCode.tableView.reloadData()
        
        viewCode.tableView.setContentOffset(CGPoint(x: 0, y: -viewCode.tableView.contentInset.top), animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewCode.tableView.layoutIfNeeded()
        viewCode.tableView.reloadData()
        
        let size = viewCode.tableView.contentSize

        preferredContentSize = size
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
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        viewModel.itemViewModel(for: indexPath)?.isContainer == true
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let itemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return
        }
        
        delegate?.viewHierarchyListViewController(self, didSelect: itemViewModel.reference)
    }
    
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
}
