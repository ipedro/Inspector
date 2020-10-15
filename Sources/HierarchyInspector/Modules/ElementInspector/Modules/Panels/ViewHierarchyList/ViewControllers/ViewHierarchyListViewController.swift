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
    
    // MARK: - Properties
    
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
    
    // MARK: - Init
    
    static func create(viewModel: ViewHierarchyListViewModelProtocol) -> ViewHierarchyListViewController {
        let viewController = ViewHierarchyListViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    // MARK: - Lifecycle
    
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
        
        calculatePreferredContentSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewCode.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        viewModel.clearAllCachedThumbnails()
    }
    
}

// MARK: - UITableViewDataSource

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

// MARK: - UITableViewDelegate

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
        
        viewModel.clearAllCachedThumbnails()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ViewHierarchyListTableViewCodeCell else {
            return
        }
        
        guard let viewModel = cell.viewModel, viewModel.hasCachedThumbnailView == false else {
            Console.print("cell", indexPath, "using cached view")
            return cell.renderThumbnailImage()
        }
        
        let delayInMilliseconds: Int = {
            
            let uncachedVisibleRows = tableView.indexPathsForVisibleRows?.filter {
                self.viewModel.itemViewModel(for: $0)?.hasCachedThumbnailView == false
            }
            
            let itemDelay = 300
            
            guard let firstUncachedIndexPath = uncachedVisibleRows?.first else { return itemDelay }
            
            return itemDelay * (indexPath.row - firstUncachedIndexPath.row + 1)
        }()
        
        Console.print("cell \(indexPath)", "delay: \(delayInMilliseconds)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayInMilliseconds)) {
            cell.renderThumbnailImage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let itemViewModel = viewModel.itemViewModel(for: indexPath) else {
            return
        }

        if itemViewModel.showDisclosureIndicator {
            
            delegate?.viewHierarchyListViewController(
                self,
                didSegueTo: itemViewModel.reference,
                from: viewModel.rootReference
            )
            
            viewModel.clearAllCachedThumbnails()
            return
        }
        
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let actions = viewModel.toggleContainer(at: indexPath)
        
        updateTableView(indexPath, with: actions)
    }
    
}

// MARK: - Helpers

private extension ViewHierarchyListViewController {
    
    func calculatePreferredContentSize() {
        let contentSize  = viewCode.tableView.contentSize
        let contentInset = viewCode.tableView.contentInset
        
        preferredContentSize = CGSize(
            width: min(UIScreen.main.bounds.width, 414),
            height: contentSize.height + contentInset.top + contentInset.bottom
        )
    }
    
    func updateTableView(_ indexPath: IndexPath, with actions: [ViewHierarchyListAction]) {
        guard actions.isEmpty == false else {
            return
        }
        
        let tableView = viewCode.tableView
        
        if let cell = tableView.cellForRow(at: indexPath) as? ViewHierarchyListTableViewCodeCell {
            cell.toggleCollapse(animated: true)
        }
        
        tableView.performBatchUpdates({
            
            actions.forEach {
                switch $0 {
                case let .inserted(insertIndexPaths):
                    tableView.insertRows(at: insertIndexPaths, with: .top)
                    
                case let .deleted(deleteIndexPaths):
                    tableView.deleteRows(at: deleteIndexPaths, with: .top)
                }
            }
            
        },
        completion: { [weak self] _ in
            
            UIView.animate(withDuration: 0.25) {
                
                tableView.indexPathsForVisibleRows?.forEach { indexPath in
                    guard let cell = tableView.cellForRow(at: indexPath) as? ViewHierarchyListTableViewCodeCell else {
                        return
                    }
                    
                    cell.isEvenRow = indexPath.row % 2 == 0
                }
                
            }
            
            self?.calculatePreferredContentSize()
            
        })
    }
}
