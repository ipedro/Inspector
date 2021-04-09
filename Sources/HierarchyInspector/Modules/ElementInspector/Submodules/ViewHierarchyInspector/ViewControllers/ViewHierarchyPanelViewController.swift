//
//  ViewHierarchyPanelViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

protocol ElementInspectorViewHierarchyInspectorViewControllerDelegate: OperationQueueManagerProtocol {
    func viewHierarchyListViewController(_ viewController: ElementInspector.ViewHierarchyPanelViewController, didSelectInfo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference)
    
    func viewHierarchyListViewController(_ viewController: ElementInspector.ViewHierarchyPanelViewController, didSegueTo reference: ViewHierarchyReference, from rootReference: ViewHierarchyReference)
}

extension ElementInspector {
    final class ViewHierarchyPanelViewController: ElementInspectorPanelViewController {
        
        // MARK: - Properties
        
        weak var delegate: ElementInspectorViewHierarchyInspectorViewControllerDelegate?
        
        private var needsSetup = true
        
        private(set) lazy var viewCode = ViewHierarchyInspectorViewCode(
            frame: CGRect(
                origin: .zero,
                size: ElementInspector.appearance.panelPreferredCompressedSize
            )
        ).then {
            $0.tableView.dataSource = self
            $0.tableView.delegate = self
            $0.tableView.reloadData()
        }
        
        var viewModel: ViewHierarchyInspectorViewModelProtocol!
        
        // MARK: - Init
        
        static func create(viewModel: ViewHierarchyInspectorViewModelProtocol) -> ElementInspector.ViewHierarchyPanelViewController {
            let viewController = ElementInspector.ViewHierarchyPanelViewController()
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
        
        func calculatePreferredContentSize() -> CGSize {
            let contentHeight = viewCode.tableView.estimatedRowHeight * CGFloat(viewModel.numberOfRows)
            let contentInset  = viewCode.tableView.contentInset
            
            return CGSize(
                width: ElementInspector.appearance.panelPreferredCompressedSize.width,
                height: contentHeight + contentInset.top + contentInset.bottom
            )
        }
        
    }
}
