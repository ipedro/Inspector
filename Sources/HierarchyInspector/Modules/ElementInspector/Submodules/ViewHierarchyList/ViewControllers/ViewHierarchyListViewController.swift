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
    ).then {
        $0.tableView.dataSource = self
        $0.tableView.delegate   = self
    }
    
    var viewModel: ViewHierarchyListViewModelProtocol!
    
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
        
        updatePreferredContentSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.shouldDisplayThumbnails = true
        
        viewCode.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.shouldDisplayThumbnails = false
        
        viewModel.clearAllCachedThumbnails()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        viewModel.clearAllCachedThumbnails()
    }
    
    func calculatePreferredContentSize() -> CGSize {
        let contentSize  = viewCode.tableView.contentSize
        let contentInset = viewCode.tableView.contentInset
        
        return CGSize(
            width: min(UIScreen.main.bounds.width, 414),
            height: contentSize.height + contentInset.top + contentInset.bottom
        )
    }
    
}
