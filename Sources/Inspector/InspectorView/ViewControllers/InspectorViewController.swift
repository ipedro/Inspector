//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import GameController
@_implementationOnly import UIKeyboardAnimatable
@_implementationOnly import UIKeyCommandTableView
import UIKit

protocol InspectorViewControllerDelegate: AnyObject {
    func inspectorViewController(_ viewController: InspectorViewController, didSelect command: InspectorCommand?)
    func inspectorViewControllerDidFinish(_ viewController: InspectorViewController)
}

final class InspectorViewController: UIViewController, InternalViewProtocol, KeyboardAnimatable {
    // MARK: - Properties

    private(set) var isFinishing = false

    weak var delegate: InspectorViewControllerDelegate?

    override var canBecomeFirstResponder: Bool { true }

    override func becomeFirstResponder() -> Bool {
        if isFinishing { return false }

        if viewCode.searchView.isFirstResponder {
            defer {
                if shouldToggleFirstResponderOnAppear { viewCode.tableView.selectNextRow() }
            }
            return viewCode.tableView.becomeFirstResponder()
        }
        if shouldToggleFirstResponderOnAppear {
            return viewCode.searchView.becomeFirstResponder()
        }
        return super.becomeFirstResponder()
    }

    private var shouldToggleFirstResponderOnAppear: Bool {
        #if targetEnvironment(simulator)
        return true
        #else

        if #available(iOS 14.0, *) {
            return GCKeyboard.coalesced != nil
        }

        return false
        #endif
    }

    private lazy var searchKeyCommands: [UIKeyCommand] = {
        var keyCommands = CharacterSet.urlQueryAllowed.allCharacters().map {
            UIKeyCommand(.key($0), action: #selector(type))
        }

        keyCommands.append(
            UIKeyCommand(.backspace, action: #selector(backspaceKey))
        )

        return keyCommands
    }()

    // MARK: - Components

    private(set) var viewModel: HierarchyInspectorViewModelProtocol!

    private var isObservingTableViewContentSize = false {
        didSet {
            guard oldValue != isObservingTableViewContentSize else { return }
            if isObservingTableViewContentSize {
                viewCode.tableView.addObserver(self, forKeyPath: .contentSize, options: .new, context: nil)
            }
            else {
                viewCode.tableView.removeObserver(self, forKeyPath: .contentSize)
            }
        }
    }

    private(set) lazy var viewCode = HierarchyInspectorViewCode().then {
        $0.delegate = self
        $0.searchView.textField.addTarget(self, action: #selector(search), for: .editingChanged)
        $0.searchView.textField.delegate = self
        $0.searchView.textField.keyPressHandler = { [weak self] key in
            guard let self = self else { return true }
            switch key?.keyCode {
            case .keyboardUpArrow:
                defer { self.setFirstResponderAndSelectPreviousRow() }
                return false
            case .keyboardTab, .keyboardDownArrow:
                defer { self.setFirstResponderAndSelectFirstRow() }
                return false
            default:
                return true
            }
        }

        $0.tableView.register(HierarchyInspectorActionTableViewCell.self)
        $0.tableView.register(HierarchyInspectorReferenceSummaryTableViewCell.self)
        $0.tableView.registerHeaderFooter(HierarchyInspectorTableViewHeaderView.self)
        $0.tableView.delegate = self
        $0.tableView.dataSource = self
        $0.tableView.keyCommandsDelegate = self
    }

    // MARK: - Init

    convenience init(viewModel: HierarchyInspectorViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = viewCode
    }

    @objc private func dismissKeyPressed() {
        if viewCode.tableView.isFirstResponder {
            viewCode.tableView.resignFirstResponder()
        }
        else {
            finish()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
        isObservingTableViewContentSize = true
        registerNavigationKeyCommands()

        if viewModel.shouldAnimateKeyboard {
            registerKeyboardAnimations()
        }
    }

    private func registerKeyboardAnimations() {
        animateWhenKeyboard(.willChangeFrame) { [weak self] info in
            guard let self = self else { return }
            self.viewCode.keyboardFrame = info.keyboardFrame
            self.viewCode.layoutIfNeeded()
        }
    }

    private func registerNavigationKeyCommands() {
        addKeyCommand(dismissModalKeyCommand(action: #selector(dismissKeyPressed)))
        addKeyCommand(UIKeyCommand(.tab, action: #selector(focusSearchField)))
        addKeyCommand(UIKeyCommand(.arrowDown, action: #selector(setFirstResponderAndSelectFirstRow)))
        addKeyCommand(UIKeyCommand(.arrowUp, action: #selector(setFirstResponderAndSelectPreviousRow)))
        addKeyCommand(
            UIKeyCommand(
                .discoverabilityTitle(
                    title: Texts.dismissView,
                    key: Inspector.sharedInstance.configuration.keyCommands.presentationSettings.options
                ),
                action: #selector(finish)
            )
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewCode.updateTableViewHeight()

        if animated {
            viewCode.transform = .init(scaleX: 0.8, y: 0.8)
            viewCode.animate(.out, duration: .average * 1.5)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if animated {
            viewCode.animate(.in)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        finish()
    }

    // MARK: - Overrides

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard
            keyPath == .contentSize,
            let contentSize = change?[.newKey] as? CGSize
        else {
            return
        }
        viewCode.tableViewContentSize = contentSize
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        startDismissing(animated: flag)
        super.dismiss(animated: flag, completion: completion)
    }

    private func startDismissing(animated: Bool) {
        isFinishing = true
        view.endEditing(true)

        if animated {
            viewCode.animate(.out)
        }
    }
}

// MARK: - DataReloading

extension InspectorViewController: DataReloadingProtocol {
    @objc func reloadData() {
        viewModel.loadData()
        viewCode.reloadData()
        viewCode.updateTableViewHeight()

        if viewCode.searchView.separatorView.isSafelyHidden != viewModel.isEmpty {
            viewCode.searchView.separatorView.isSafelyHidden = viewModel.isEmpty
        }

        if viewCode.tableView.isSafelyHidden != viewModel.isEmpty {
            viewCode.tableView.isSafelyHidden = viewModel.isEmpty
        }
    }
}

// MARK: - KeyCommand

extension InspectorViewController {
    func addSearchKeyCommandListeners() {
        searchKeyCommands.forEach { addKeyCommand($0) }
    }

    func removeSearchKeyCommandListeners() {
        searchKeyCommands.forEach { removeKeyCommand($0) }
    }
}

// MARK: - First Responder

@objc extension InspectorViewController {
    func setFirstResponderAndSelectPreviousRow() {
        viewCode.tableView.becomeFirstResponder()
        viewCode.tableView.selectPreviousRow()
    }

    func setFirstResponderAndSelectFirstRow() {
        viewCode.tableView.becomeFirstResponder()
        viewCode.tableView.selectNextRow()
    }

    @discardableResult
    func focusSearchField() -> Bool {
        viewCode.searchView.becomeFirstResponder()
    }
}

// MARK: - Keyboard Handlers

@objc private extension InspectorViewController {
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
        debounce(#selector(search), delay: .veryLong)
    }

    func backspaceKey() {
        viewCode.searchView.deleteBackward()
        debounce(#selector(search), delay: .veryLong)
    }

    func search() {
        if viewCode.searchView.isFirstResponder == false {
            viewCode.tableView.resignFirstResponder()
        }

        guard viewCode.searchView.isFirstResponder else { return }

        viewModel.search(viewCode.searchView.query) {
            self.reloadData()
            DispatchQueue.main.async {
                self.scrollToTopSection()
            }
        }
    }

    @objc private func scrollToTopSection() {
        if viewCode.tableView.contentOffset.y > 100 {
            viewCode.tableView.scrollToRow(
                at: IndexPath(
                    row: NSNotFound,
                    section: .zero
                ),
                at: .top,
                animated: false
            )
        }
    }

    func finish() {
        guard !isFinishing else { return }
        isFinishing = true
        if isViewLoaded {
            isObservingTableViewContentSize = false
            viewCode.endEditing(true)
            stopAnimatingWhenKeyboard(.willChangeFrame)
        }
        delegate?.inspectorViewControllerDidFinish(self)
    }
}

// MARK: - HierarchyInspectorViewDelegate

extension InspectorViewController: HierarchyInspectorViewCodeDelegate {
    func hierarchyInspectorViewCodeDidTapOutside(_ view: HierarchyInspectorViewCode) {
        finish()
    }
}

// MARK: - UITextFieldDelegate

extension InspectorViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string == UIKeyCommand.inputTab {
            DispatchQueue.main.async {
                self.setFirstResponderAndSelectFirstRow()
            }
            return false
        }
        return true
    }
}

private extension String {
    static let contentSize = "contentSize"
}
