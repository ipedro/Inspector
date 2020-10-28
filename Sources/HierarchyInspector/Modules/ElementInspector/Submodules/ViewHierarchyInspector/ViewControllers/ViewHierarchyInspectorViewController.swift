//
//  ViewHierarchyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ViewHierarchyInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    func viewHierarchyListViewController(_ viewController: ViewHierarchyInspectorViewController, didSelectInfo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference)
    
    func viewHierarchyListViewController(_ viewController: ViewHierarchyInspectorViewController, didSegueTo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference)
}

final class ViewHierarchyInspectorViewController: ElementInspectorPanelViewController {
    
    // MARK: - Properties
    
    weak var delegate: ViewHierarchyInspectorViewControllerDelegate?
    
    private var needsSetup = true
    
    private(set) lazy var viewCode = ViewHierarchyInspectorViewCode(
        frame: CGRect(
            origin: .zero,
            size: ElementInspector.configuration.appearance.panelPreferredCompressedSize
        )
    )
    
    var viewModel: ViewHierarchyInspectorViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    // MARK: - Init
    
    static func create(viewModel: ViewHierarchyInspectorViewModelProtocol) -> ViewHierarchyInspectorViewController {
        let viewController = ViewHierarchyInspectorViewController()
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

extension ViewHierarchyInspectorViewController: ViewHierarchyInspectorViewModelDelegate {
    func viewHierarchyListViewModelDidLoad(_ viewModel: ViewHierarchyInspectorViewModelProtocol) {
        viewCode.activityIndicatorView.stopAnimating()
        
        viewCode.tableView.dataSource = self
        viewCode.tableView.delegate = self
        viewCode.tableView.reloadData()
    }
}
