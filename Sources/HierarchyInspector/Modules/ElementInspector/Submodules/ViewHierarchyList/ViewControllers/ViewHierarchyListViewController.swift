//
//  ViewHierarchyListViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ViewHierarchyListViewControllerDelegate: OperationQueueManagerProtocol {
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSelectInfo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference)
    
    func viewHierarchyListViewController(_ viewController: ViewHierarchyListViewController, didSegueTo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference)
}

final class ViewHierarchyListViewController: ElementInspectorPanelViewController {
    
    // MARK: - Properties
    
    weak var delegate: ViewHierarchyListViewControllerDelegate?
    
    private var needsSetup = true
    
    #warning("remove magic number")
    private(set) lazy var viewCode = ViewHierarchyListViewCode(
        frame: CGRect(
            origin: .zero,
            size: CGSize(
                width: min(UIScreen.main.bounds.width, 414),
                height: .zero
            )
        )
    )
    
    var viewModel: ViewHierarchyListViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewCode.tableView.indexPathsForSelectedRows?.forEach {
            viewCode.tableView.deselectRow(at: $0, animated: animated)
        }
        
        updatePreferredContentSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let loadOperation = MainThreadOperation(name: "load data") { [weak self] in
            self?.viewModel.loadData()
        }
        
        delegate?.addBarrierOperation(loadOperation)
    }
    
    func calculatePreferredContentSize() -> CGSize {
        let contentHeight = viewCode.tableView.estimatedRowHeight * CGFloat(viewModel.numberOfRows)
        let contentInset = viewCode.tableView.contentInset
        
        return CGSize(
            width: min(UIScreen.main.bounds.width, 414),
            height: contentHeight + contentInset.top + contentInset.bottom
        )
    }
    
}

extension ViewHierarchyListViewController: ViewHierarchyListViewModelDelegate {
    func viewHierarchyListViewModelDidLoad(_ viewModel: ViewHierarchyListViewModelProtocol) {
        viewCode.activityIndicatorView.stopAnimating()
        
        viewCode.tableView.dataSource = self
        viewCode.tableView.delegate = self
        viewCode.tableView.reloadData()
    }
}
