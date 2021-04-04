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
    
    private(set) var viewModel: HierarchyInspectorViewModelProtocol!
    
    private(set) lazy var viewCode = HierarchyInspectorView().then {
        $0.delegate = self
    }
    
    private(set) lazy var headers = [Int: HierarchyInspectorHeaderView]()
    
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
    
    func dequeueHeaderView(in section: Int) -> HierarchyInspectorHeaderView? {
        if let headerView = headers[section] {
            return headerView
        }
        
        let headerView = HierarchyInspectorHeaderView()
        headerView.title = viewModel.titleForHeader(in: section)
        
        headers[section] = headerView
        
        return headerView
    }
}

// MARK: - Keyboard Handlers

@objc private extension HierarchyInspectorViewController {
    func keyboardWillHide(_ notification: Notification) {
        animateWithKeyboard(notification: notification) { properties in
            self.viewCode.keyboardFrame = nil
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        animateWithKeyboard(notification: notification) { properties in
            self.viewCode.keyboardFrame = properties.keyboardFrame
        }
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
