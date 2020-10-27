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
    
    private(set) lazy var viewCode = ViewHierarchyListViewCode(
        frame: CGRect(
            origin: .zero,
            size: ElementInspector.configuration.appearance.panelPreferredCompressedSize
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
        
        viewModel.loadOperations().forEach {
            delegate?.addOperationToQueue($0)
        }
    }
    
    func calculatePreferredContentSize() -> CGSize {
        let contentHeight = viewCode.tableView.estimatedRowHeight * CGFloat(viewModel.numberOfRows)
        let contentInset  = viewCode.tableView.contentInset
        
        return CGSize(
            width: ElementInspector.configuration.appearance.panelPreferredCompressedSize.width,
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
