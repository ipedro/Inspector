//
//  ElementViewHierarchyViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ElementInspectorViewHierarchyInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    func viewHierarchyListViewController(_ viewController: ElementViewHierarchyViewController, didSelectInfo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference)
    
    func viewHierarchyListViewController(_ viewController: ElementViewHierarchyViewController, didSegueTo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference)
}

final class ElementViewHierarchyViewController: ElementInspectorPanelViewController {
    
    // MARK: - Properties
    
    weak var delegate: ElementInspectorViewHierarchyInspectorViewControllerDelegate?
    
    private var needsSetup = true
    
    private(set) lazy var viewCode = ElementViewHierarchyInspectorViewCode(
        frame: CGRect(
            origin: .zero,
            size: ElementInspector.appearance.panelPreferredCompressedSize
        )
    ).then {
        $0.tableView.register(ElementViewHierarchyInspectorTableViewCodeCell.self)
        $0.tableView.dataSource = self
        $0.tableView.delegate = self
    }
    
    var viewModel: ElementViewHierarchyInspectorViewModelProtocol!
    
    // MARK: - Init
    
    static func create(viewModel: ElementViewHierarchyInspectorViewModelProtocol) -> ElementViewHierarchyViewController {
        let viewController = ElementViewHierarchyViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
        
        updatePreferredContentSize()
    }
    
    func reloadData() {
        viewModel.reloadIcons()
        viewCode.tableView.reloadData()
    }
    
    func calculatePreferredContentSize() -> CGSize {
        let contentHeight = viewCode.tableView.estimatedRowHeight * CGFloat(viewModel.numberOfRows)
        let contentInset  = viewCode.tableView.contentInset
        
        return CGSize(
            width: ElementInspector.appearance.panelPreferredCompressedSize.width,
            height: contentHeight + contentInset.top + contentInset.bottom
        )
    }
    
}
