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
    
    // MARK: - Properties
    
    weak var delegate: HierarchyInspectorViewControllerDelegate?
    
    private(set) var viewModel: HierarchyInspectorViewModelProtocol!
    
    private(set) lazy var viewCode = HierarchyInspectorView().then {
        $0.delegate = self
        
        $0.searchView.textField.addTarget(self, action: #selector(search), for: .editingChanged)
        $0.searchView.textField.delegate = self
        
        $0.tableView.addObserver(self, forKeyPath: .contentSize, options: .new, context: nil)
        $0.tableView.register(HierarchyInspectorLayerActionCell.self)
        $0.tableView.register(HierarchyInspectorSnapshotCell.self)
        $0.tableView.registerHeaderFooter(HierarchyInspectorHeaderView.self)
        $0.tableView.delegate = self
        $0.tableView.dataSource = self
        $0.tableView.keyboardSelectionDelegate = self
    }
    
    private var needsSetup = true
    
    private var isClosing = false
    
    override func loadView() {
        view = viewCode
    }
    
    deinit {
        viewCode.tableView.removeObserver(self, forKeyPath: .contentSize, context: nil)
    }
    
    @objc
    func upArrow() {
        toggleFirstResponder()
        viewCode.tableView.selectRow(at: viewCode.tableView.indexPathForLastRowInLastSection)
    }
    
    @objc
    func downArrow() {
        toggleFirstResponder()
        viewCode.tableView.selectRow(at: .first)
    }
    
    @objc
    func toggleFirstResponder() {
        switch viewCode.searchView.isFirstResponder {
        case true:
            viewCode.searchView.resignFirstResponder()
            viewCode.tableView.becomeFirstResponder()
        
        case false:
            viewCode.tableView.resignFirstResponder()
            viewCode.searchView.becomeFirstResponder()
        }
    }
    
    // MARK: - Overrides
    
    private lazy var searchKeyCommands: [UIKeyCommand] = {
        var keyCommands = CharacterSet.urlQueryAllowed.allCharacters().map {
            UIKeyCommand(
                input: String($0),
                action: #selector(type)
            )
        }
        
        keyCommands.append(
            UIKeyCommand(
                input: UIKeyCommand.inputBackspace,
                action: #selector(backspace)
            )
        )
        
        return keyCommands
    }()
    
    private func addSearchKeyCommandListeners() {
        searchKeyCommands.forEach { addKeyCommand($0) }
    }
    private func removeSearchKeyCommandListeners() {
        searchKeyCommands.forEach { removeKeyCommand($0) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // key commands
        
        addKeyCommand(UIViewController.dismissModalKeyCommand)
        addKeyCommand(
            UIKeyCommand(
                input: UIKeyCommand.inputTab,
                action: #selector(downArrow)
            )
        )
        addKeyCommand(
            UIKeyCommand(
                input: UIKeyCommand.inputUpArrow,
                action: #selector(upArrow)
            )
        )
        addKeyCommand(
            UIKeyCommand(
                input: UIKeyCommand.inputDownArrow,
                action: #selector(downArrow)
            )
        )
        
        // keyboard event listeners
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
            self.toggleFirstResponder()
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        view.endEditing(true)
        
        super.dismiss(animated: flag, completion: completion)
        
        if flag  {
            viewCode.animate(.out)
        }
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        viewModel.loadData()
        
        viewCode.searchView.separatorView.isSafelyHidden = viewModel.isEmpty
        
        viewCode.tableView.isSafelyHidden = viewModel.isEmpty
                
        viewCode.tableView.reloadData()
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
    
    func type(_ sender: Any) {
        guard
            let keyCommand = sender as? UIKeyCommand,
            let keyCommandInput = keyCommand.input
        else {
            return
        }
        
        let character: String = {
            switch keyCommand.modifierFlags {
            case .alphaShift:
                return keyCommandInput
                
            default:
                return keyCommandInput.lowercased()
            }
        }()
        
        viewCode.searchView.insertText(character)
        search()
    }
    
    func backspace() {
        viewCode.searchView.deleteBackward()
        search()
    }
    
    func search() {
        viewCode.searchView.becomeFirstResponder()
        viewModel.searchQuery = viewCode.searchView.query
        reloadData()
        
        DispatchQueue.main.async {
            self.viewCode.tableView.scrollToRow(
                at: IndexPath(
                    row: NSNotFound,
                    section: .zero
                ),
                at: .top,
                animated: false
            )
        }
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

extension HierarchyInspectorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == UIKeyCommand.inputTab {
            DispatchQueue.main.async {
                self.toggleFirstResponder()
            }
            return false
        }
        return true
    }
}

// MARK: - KeyboardTableViewSelectionDelegate

extension HierarchyInspectorViewController: KeyboardTableViewSelectionDelegate {
    func tableViewDidBecomeFirstResponder(_ tableView: UITableView) {
        addSearchKeyCommandListeners()
    }
    
    func tableViewDidResignFirstResponder(_ tableView: UITableView) {
        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: false) }
        removeSearchKeyCommandListeners()
        viewCode.searchView.becomeFirstResponder()
    }
}
