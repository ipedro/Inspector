//
//  UIKeyCommandTableView.swift
//  HierarhcyInspector
//
//  Created by Pedro on 10.04.21.
//
//  Inspired by:
//  Douglas Hill, December 2018: 
//  https://gist.github.com/adamyanalunas/b1ce3af40843a356dc3cade6e6ab6a21

import UIKit

protocol UITableViewKeyCommandsDelegate: AnyObject {
    func tableViewDidBecomeFirstResponder(_ tableView: UIKeyCommandTableView)
    func tableViewDidResignFirstResponder(_ tableView: UIKeyCommandTableView)
    func tableViewKeyCommandSelectionBelowBounds(_ tableView: UIKeyCommandTableView) -> UIKeyCommandTableView.OutOfBoundsBehavior
    func tableViewKeyCommandSelectionAboveBounds(_ tableView: UIKeyCommandTableView) -> UIKeyCommandTableView.OutOfBoundsBehavior
}

/// A table view that allows navigation and selection using a hardware keyboard.
/// Only supports a single section.
class UIKeyCommandTableView: UITableView {
    
    enum OutOfBoundsBehavior {
        case resignFirstResponder, wrapAround, doNothing
    }
    
    weak var keyCommandsDelegate: UITableViewKeyCommandsDelegate?
    
    override var canBecomeFirstResponder: Bool {
        !isHidden && totalNumberOfRows > 0
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let hasBecomeFirstResponder = super.becomeFirstResponder()
        
        if hasBecomeFirstResponder {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.keyCommandsDelegate?.tableViewDidBecomeFirstResponder(self)
            }
        }
        
        return hasBecomeFirstResponder
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let hasResignedFirstResponder = super.resignFirstResponder()
        
        if hasResignedFirstResponder {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.keyCommandsDelegate?.tableViewDidResignFirstResponder(self)
            }
        }
        
        return hasResignedFirstResponder
    }
    
    var selectPreviousKeyCommandOptions: [UIKeyCommand.Options] = [.arrowUp]
    
    var selectNextKeyCommandOptions: [UIKeyCommand.Options] = [.arrowDown]
    
    var activateSelectionKeyCommandOptions: [UIKeyCommand.Options] = [.spaceBar, .return]
    
    var clearSelectionKeyCommandOptions: [UIKeyCommand.Options] = []
    
    override var keyCommands: [UIKeyCommand]? {
        var keyCommands = [UIKeyCommand]()
        
        selectPreviousKeyCommandOptions.forEach {
            keyCommands.append(UIKeyCommand($0, action: #selector(selectPrevious)))
        }
        
        selectNextKeyCommandOptions.forEach {
            keyCommands.append(UIKeyCommand($0, action: #selector(selectNext)))
        }
        
        activateSelectionKeyCommandOptions.forEach {
            keyCommands.append(UIKeyCommand($0, action: #selector(activateSelection)))
        }
        
        clearSelectionKeyCommandOptions.forEach {
            keyCommands.append(UIKeyCommand($0, action: #selector(clearSelection)))
        }
        
        return keyCommands
    }
    
    var totalNumberOfRows: Int {
        (0 ..< numberOfSections).map { numberOfRows(inSection: $0) }.reduce(0, +)
    }
    
    var indexPathForLastRowInLastSection: IndexPath {
        let lastSection = numberOfSections - 1
        let lastRow     = numberOfRows(inSection: lastSection) - 1
        
        return IndexPath(row: lastRow, section: lastSection)
    }
    
    /// Tries to select and scroll to the row at the given index in section 0.
    /// Does not require the index to be in bounds. Does nothing if out of bounds.
    func selectRowIfPossible(at indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        
        switch validate(indexPath) {
            
        case .success:
            handleValidSelection(with: indexPath)
            
        case let .failure(reason):
            handleInvalidSelection(with: indexPath, reason: reason)
        }
    }
    
}

// MARK: - Selection

private extension UIKeyCommandTableView {
    
    func lastRow(in section: Int) -> Int? {
        switch validate(IndexPath(row: .zero, section: section)) {
        case .failure:
            return nil
            
        case .success:
            return numberOfRows(inSection: section) - 1
        }
    }
    
    func handleValidSelection(with indexPath: IndexPath) {
        var selectedIndexPath: IndexPath? {
            guard let delegate = delegate else {
                return indexPath
            }
            
            return delegate.tableView?(self, willSelectRowAt: indexPath)
        }
        
        if let validIndexPath = selectedIndexPath {
            return performRowSelection(at: validIndexPath)
        }
        
        switch indexPathForSelectedRow?.compare(indexPath) {
        case .orderedSame:
            return
        
        case .orderedDescending:
            selectRowIfPossible(at: indexPath.previousRow())
            
        case .none, .orderedAscending:
            selectRowIfPossible(at: indexPath.nextRow())
        }
    }
    
    func handleInvalidSelection(with indexPath: IndexPath, reason: IndexPath.InvalidReason) {
        switch reason {
        case .sectionBelowBounds:
            switch keyCommandsDelegate?.tableViewKeyCommandSelectionBelowBounds(self) {
            case .none, .doNothing:
                break
                
            case .resignFirstResponder:
                resignFirstResponder()
                
            case .wrapAround:
                selectRowIfPossible(at: indexPathForLastRowInLastSection)
            }
            
        case .sectionAboveBounds:
            switch keyCommandsDelegate?.tableViewKeyCommandSelectionAboveBounds(self) {
            case .none, .doNothing:
                break
                
            case .resignFirstResponder:
                resignFirstResponder()
                
            case .wrapAround:
                selectRowIfPossible(at: .first)
            }
            
        case .rowAboveBounds:
            selectRowIfPossible(at: indexPath.nextSection())
            
        case .rowBelowBounds:
            let section = indexPath.section - 1
            
            if let row = lastRow(in: section) {
                selectRowIfPossible(at: IndexPath(row: row, section: section))
            }
            else {
                selectRowIfPossible(at: IndexPath(row: .zero, section: section))
            }
        }
    }
    
    func performRowSelection(at indexPath: IndexPath) {
        switch isRowVisible(at: indexPath) {
        case .fullyVisible:
            selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
        case let .notFullyVisible(scrollPosition):
            selectRow(at: indexPath, animated: false, scrollPosition: .none)
            scrollToRow(at: indexPath, at: scrollPosition, animated: true)
            
            debounce(#selector(flashScrollIndicators), after: 0.2)
        }
    }
    
    func validate(_ indexPath: IndexPath) -> Result<IndexPath, IndexPath.InvalidReason> {
        guard indexPath.section >= 0 else {
            return .failure(.sectionBelowBounds)
        }
        
        guard indexPath.section < numberOfSections else {
            return .failure(.sectionAboveBounds)
        }
        
        guard indexPath.row >= 0 else {
            return .failure(.rowBelowBounds)
        }
        
        guard indexPath.row < numberOfRows(inSection: indexPath.section) else {
            return .failure(.rowAboveBounds)
        }
        
        return .success(indexPath)
    }
}

// MARK: - Key Command Handlers

@objc
private extension UIKeyCommandTableView {
    
    func clearSelection() {
        selectRow(at: nil, animated: false, scrollPosition: .none)
    }

    func activateSelection() {
        var selectableIndexPath: IndexPath? {
            guard let indexPathForSelectedRow = indexPathForSelectedRow else {
                return nil
            }
            
            guard let delegate = delegate else {
                return indexPathForSelectedRow
            }
            
            return delegate.tableView?(self, willSelectRowAt: indexPathForSelectedRow)
        }
        
        if let selectedIndexPath = selectableIndexPath {
            delegate?.tableView?(self, didSelectRowAt: selectedIndexPath)
        }
    }
    
    func selectPrevious() {
        guard let currentSelection = indexPathForSelectedRow else {
            return selectRowIfPossible(at: indexPathForLastRowInLastSection)
        }
        
        selectRowIfPossible(at: currentSelection.previousRow())
    }

    func selectNext() {
        guard let currentSelection = indexPathForSelectedRow else {
            return selectRowIfPossible(at: .first)
        }
        
        selectRowIfPossible(at: currentSelection.nextRow())
    }
}

// MARK: - Row Visibility

private extension UIKeyCommandTableView {
    
    /// Whether a row is fully visible, or if not if it’s above or below the viewport.
    enum RowVisibility {
        case fullyVisible
        case notFullyVisible(ScrollPosition)
    }

    /// Whether the given row is fully visible, or if not if it’s above or below the viewport.
    func isRowVisible(at indexPath: IndexPath) -> RowVisibility {
        let rowRect = rectForRow(at: indexPath)
        
        if bounds.inset(by: adjustedContentInset).contains(rowRect) {
            return .fullyVisible
        }

        let position: ScrollPosition = rowRect.midY < bounds.midY ? .top : .bottom
        
        return .notFullyVisible(position)
    }
    
}
