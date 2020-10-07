//
//  ViewHierarchyListViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListViewController: UIViewController {
    private(set) lazy var hierarchyInspectorManager = HierarchyInspector.Manager(host: self)
    
    private lazy var viewCode = ViewHierarchyListViewCode().then {
        $0.tableView.dataSource = self
        $0.tableView.delegate = self
        $0.inspectBarButtonItem.target = self
        $0.inspectBarButtonItem.action = #selector(toggleInspect)
    }
    
    private var viewModel: ViewHierarchyListViewModelProtocol!
    
    override func loadView() {
        view = viewCode
        
        navigationItem.rightBarButtonItem = viewCode.inspectBarButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        preferredContentSize = CGSize(width: 320, height: 480)
    }
    
    static func create(viewModel: ViewHierarchyListViewModelProtocol) -> ViewHierarchyListViewController {
        let viewController = ViewHierarchyListViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    @objc func toggleInspect() {
        switch hierarchyInspectorManager.isShowingLayers {
        case true:
            hierarchyInspectorManager.removeAllLayers()
            
        case false:
            hierarchyInspectorManager.installAllLayers()
        }
    }
}

extension ViewHierarchyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ViewHierarchyListTableViewCodeCell.self, for: indexPath)
        
        let cellViewModel = viewModel.itemViewModel(for: indexPath)
        
        cell.viewModel = cellViewModel
        
        return cell
    }
}

extension ViewHierarchyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let result = viewModel.toggleContainer(at: indexPath) else {
            tableView.reloadRows(at: [indexPath], with: .none)
            return
        }
        
        tableView.performBatchUpdates({
            switch result {
            case let .inserted(indexPaths):
                tableView.insertRows(at: indexPaths, with: .top)
                
            case let .deleted(indexPaths):
                tableView.deleteRows(at: indexPaths, with: .top)
            }
            
            tableView.reloadRows(at: [indexPath], with: .none)
        },
        completion: { _ in
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        })
    }
}

extension ViewHierarchyListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension ViewHierarchyListViewController: HierarchyInspectorPresentable {
    var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        [.allViews, .staticTexts, .containerViews]
    }
}

