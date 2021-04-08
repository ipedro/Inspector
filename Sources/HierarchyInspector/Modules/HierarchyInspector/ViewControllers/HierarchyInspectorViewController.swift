//
//  HierarchyInspectorViewController.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.04.21.
//

import UIKit

protocol HierarchyInspectorViewControllerDelegate: AnyObject {
    func hierarchyInspectorViewController(_ viewController: HierarchyInspectorViewController, didSelect viewHierarchyReference: ViewHierarchyReference)
}

final class HierarchyInspectorViewController: UIViewController, KeyboardAnimatable {

    static func create(viewModel: HierarchyInspectorViewModelProtocol) -> HierarchyInspectorViewController {
        let viewController = HierarchyInspectorViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    weak var delegate: HierarchyInspectorViewControllerDelegate?
    
    private(set) var viewModel: HierarchyInspectorViewModelProtocol!
    
    private(set) lazy var viewCode = HierarchyInspectorView().then {
        $0.delegate = self
        
        $0.searchView.textField.addTarget(self, action: #selector(search(_:)), for: .allEditingEvents)
        
        $0.tableView.addObserver(self, forKeyPath: .contentSize, options: .new, context: nil)
        $0.tableView.register(HierarchyInspectorTableViewCell.self)
        $0.tableView.registerHeaderFooter(HierarchyInspectorHeaderView.self)
        $0.tableView.delegate = self
        $0.tableView.dataSource = self
    }
    
    private var needsSetup = true
    
    private var isClosing = false
    
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
    
    deinit {
        viewCode.tableView.removeObserver(self, forKeyPath: .contentSize, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard
            keyPath == .contentSize,
            let contentSize = change?[.newKey] as? CGSize
        else {
            return
        }
        
        viewCode.tableViewContentSize = contentSize
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
        
        reloadData()
        
        DispatchQueue.main.async {
            _ = self.viewCode.searchView.becomeFirstResponder()
        }
    }
    
    func reloadData() {
        viewModel.loadData()
        
        viewCode.searchView.separatorView.isSafelyHidden = viewModel.isEmpty
        
        viewCode.tableView.isSafelyHidden = viewModel.isEmpty
                
        viewCode.layoutIfNeeded()
        
        viewCode.tableView.reloadData()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        view.endEditing(true)
        
        super.dismiss(animated: flag, completion: completion)
        
        if flag  {
            viewCode.animate(.out)
        }
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
    
    func search(_ sender: Any) {
        viewModel.searchQuery = viewCode.searchView.textField.text
        reloadData()
    }
}

// MARK: - HierarchyInspectorViewDelegate

extension HierarchyInspectorViewController: HierarchyInspectorViewDelegate {
    func hierarchyInspectorViewDidTapOutside(_ view: HierarchyInspectorView) {
        if isClosing {
            return
        }
        
        isClosing = true
        
        dismiss(animated: true)
    }
}

fileprivate extension String {
    static let contentSize = "contentSize"
}
