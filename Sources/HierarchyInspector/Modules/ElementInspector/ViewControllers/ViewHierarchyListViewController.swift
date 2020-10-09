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
        $0.tableView.delegate   = self
        
        $0.inspectBarButtonItem.target = self
        $0.inspectBarButtonItem.action = #selector(toggleInspect)
        
        $0.dismissBarButtonItem.target = self
        $0.dismissBarButtonItem.action = #selector(close)
    }
    
    private var viewModel: ViewHierarchyListViewModelProtocol!
    
    override func loadView() {
        view = viewCode
        
        navigationItem.rightBarButtonItem = viewCode.inspectBarButtonItem
        navigationItem.leftBarButtonItem = viewCode.dismissBarButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize = viewCode.tableView.contentSize
    }
    
    static func create(viewModel: ViewHierarchyListViewModelProtocol) -> ViewHierarchyListViewController {
        let viewController = ViewHierarchyListViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    @objc func toggleInspect() {
        presentHierarchyInspector(animated: true)
    }
    
    @objc func close() {
        dismiss(animated: true)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let text = viewModel.title(for: section)
        
        return SectionHeader(text: text)
    }
}

extension ViewHierarchyListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension ViewHierarchyListViewController: HierarchyInspectorPresentable {
    var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        [.staticTexts, .controls, .icons]
    }
}

extension HierarchyInspector.Layer {
    static let icons: HierarchyInspector.Layer = .layer(name: "Icons") { $0 is Icon }
}
