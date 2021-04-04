//
//  HierarchyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.04.21.
//

import UIKit

final class HierarchyInspectorViewController: UIViewController, KeyboardAnimatable {

    static func create(viewModel: HierarchyInspectorViewModelProtocol) -> HierarchyInspectorViewController {
        let viewController = HierarchyInspectorViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    private var viewModel: HierarchyInspectorViewModelProtocol!
    
    private lazy var viewCode = HierarchyInspectorView().then {
        $0.delegate = self
    }
    
    private lazy var headers = [Int: HierarchyInspectorHeaderView]()
    
    private var needsSetup = true
    
    override func loadView() {
        view = viewCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard needsSetup else {
            return
        }
        
        needsSetup = false
        
        if animated {
            viewCode.animate(.in)
        }
        
        viewCode.tableView.delegate = self
        viewCode.tableView.dataSource = self
        
        DispatchQueue.main.async {
            _ = self.viewCode.searchView.becomeFirstResponder()
        }
    }
    
}

private extension HierarchyInspectorViewController {
    @objc func keyboardWillHide(_ notification: Notification) {
        animateWithKeyboard(notification: notification) { properties in
            self.viewCode.keyboardFrame = nil
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        animateWithKeyboard(notification: notification) { properties in
            self.viewCode.keyboardFrame = properties.keyboardFrame
        }
    }
    
}

// MARK: - UITableViewDataSource

extension HierarchyInspectorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(HierarchyInspectorTableViewCell.self, for: indexPath)
        cell.textLabel?.text = viewModel.titleForRow(at: indexPath)
        cell.directionalLayoutMargins = .allMargins(ElementInspector.appearance.horizontalMargins)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HierarchyInspectorViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            let firstVisibleSection = viewCode.tableView.indexPathsForVisibleRows?.first?.section,
            let headerView = headers[firstVisibleSection]
        else {
            return
        }
        
        for cell in viewCode.tableView.visibleCells {
            guard let cell = cell as? HierarchyInspectorTableViewCell else {
                return
            }
            
            let headerHeight: CGFloat = headerView.frame.height
            
            let hiddenFrameHeight = scrollView.contentOffset.y + headerHeight - cell.frame.origin.y
            
            if hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height {
                cell.maskCellFromTop(margin: hiddenFrameHeight)
            }
            else {
                break
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        dequeueHeaderView(in: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Console.print(indexPath)
    }
    
    private func dequeueHeaderView(in section: Int) -> HierarchyInspectorHeaderView? {
        if let headerView = headers[section] {
            return headerView
        }
        
        let headerView = HierarchyInspectorHeaderView()
        headerView.title = viewModel.titleForHeader(in: section)
        
        headers[section] = headerView
        
        return headerView
    }
}

// MARK: - HierarchyInspectorViewDelegate

extension HierarchyInspectorViewController: HierarchyInspectorViewDelegate {
    
    func hierarchyInspectorViewDidTapOutside(_ view: HierarchyInspectorView) {
        view.endEditing(true)
        dismiss(animated: true)
        viewCode.animate(.out)
    }
    
}
