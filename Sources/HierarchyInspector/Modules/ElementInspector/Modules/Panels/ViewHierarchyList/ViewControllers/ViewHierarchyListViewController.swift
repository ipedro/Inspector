//
//  ViewHierarchyListViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ViewHierarchyListViewControllerDelegate: AnyObject {
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController,
                                         didSelectInfo reference: ViewHierarchyReference,
                                         from rootReference: ViewHierarchyReference)
    
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController,
                                         didSegueTo reference: ViewHierarchyReference,
                                         from rootReference: ViewHierarchyReference)
}

final class ViewHierarchyListViewController: UIViewController {
    weak var delegate: ViewHierarchyListViewControllerDelegate?
    
    private var needsSetup = true
    
    private lazy var viewCode = ViewHierarchyListViewCode(
        frame: CGRect(
            origin: .zero,
            size: CGSize(
                width: min(UIScreen.main.bounds.width, 414),
                height: .zero
            )
        )
    ).then {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewCode.tableView.indexPathsForSelectedRows?.forEach {
            viewCode.tableView.deselectRow(at: $0, animated: animated)
        }
        
        preferredContentSize = CGSize(
            width: min(UIScreen.main.bounds.width, 414),
            height: viewCode.tableView.contentSize.height
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewCode.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        viewModel.clearAllCachedThumbnails()
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
        guard let itemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return false
        }
        
        return itemViewModel.isContainer == true || itemViewModel.showDisclosureIndicator
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let itemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return
        }
        
        delegate?.viewHierarchyListViewController(self, didSelectInfo: itemViewModel.reference, from: viewModel.rootReference)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ViewHierarchyListTableViewCodeCell else {
            return
        }
        
        guard
            let viewModel = cell.viewModel, viewModel.hasCachedThumbnailView == false,
            let firstVisibleRow = tableView.indexPathsForVisibleRows?.first
        else {
            Console.print("cell", indexPath, "using cached view")
            
            return cell.renderThumbnailImage()
        }
        
        let milliseconds = 300 * max(1, indexPath.row - firstVisibleRow.row)
        
        Console.print("cell", indexPath, "delay", milliseconds)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
            cell.renderThumbnailImage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let itemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return
        }

        if itemViewModel.showDisclosureIndicator {
            delegate?.viewHierarchyListViewController(self, didSegueTo: itemViewModel.reference, from: viewModel.rootReference)
            
            itemViewModel.clearCachedThumbnail()
            
            return
        }
        
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
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
