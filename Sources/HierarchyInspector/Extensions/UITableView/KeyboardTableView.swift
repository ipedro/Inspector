//
//  KeyboardTableView.swift
//  HierarhcyInspector
//
//  Created by Pedro on 10.04.21.
//
//  Inspired by:
//  Douglas Hill, December 2018: 
//  https://gist.github.com/adamyanalunas/b1ce3af40843a356dc3cade6e6ab6a21

import UIKit

protocol KeyboardTableViewSelectionDelegate: AnyObject {
    func tableViewDidBecomeFirstResponder(_ tableView: UITableView)
    func tableViewDidResignFirstResponder(_ tableView: UITableView)
}

/// A table view that allows navigation and selection using a hardware keyboard.
/// Only supports a single section.
class KeyboardTableView: UITableView {
    
    weak var keyboardSelectionDelegate: KeyboardTableViewSelectionDelegate?
    
    override var canBecomeFirstResponder: Bool {
        !isHidden && totalNumberOfRows > 0
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let hasBecomeFirstResponder = super.becomeFirstResponder()
        
        if hasBecomeFirstResponder {
            DispatchQueue.main.async {
                self.keyboardSelectionDelegate?.tableViewDidBecomeFirstResponder(self)
            }
        }
        
        return hasBecomeFirstResponder
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let hasResignedFirstResponder = super.resignFirstResponder()
        
        if hasResignedFirstResponder {
            DispatchQueue.main.async {
                self.keyboardSelectionDelegate?.tableViewDidResignFirstResponder(self)
            }
        }
        
        return hasResignedFirstResponder
    }
    
    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(input: UIKeyCommand.inputUpArrow,   action: #selector(selectPrevious)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, action: #selector(selectNext)),
            //UIKeyCommand(input: UIKeyCommand.inputEscape,    action: #selector(clearSelection)),
            UIKeyCommand(input: UIKeyCommand.inputSpaceBar,  action: #selector(activateSelection)),
            UIKeyCommand(input: UIKeyCommand.inputReturn,    action: #selector(activateSelection))
        ]
    }
    
    var totalNumberOfRows: Int {
        var rows = 0
        
        for section in 0..<numberOfSections {
            rows += numberOfRows(inSection: section)
        }
        
        return rows
    }
    
    var indexPathForLastRowInLastSection: IndexPath {
        let lastSection = numberOfSections - 1
        let lastRow     = numberOfRows(inSection: lastSection) - 1
        
        return IndexPath(row: lastRow, section: lastSection)
    }
    
    private func lastRow(in section: Int) -> Int? {
        switch validate(IndexPath(row: .zero, section: section)) {
        case .failure:
            return nil
            
        case .success:
            return numberOfRows(inSection: section) - 1
        }
    }
    
    /// Tries to select and scroll to the row at the given index in section 0.
    /// Does not require the index to be in bounds. Does nothing if out of bounds.
    func selectRow(at indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        
        switch validate(indexPath) {
        case let .failure(reason):
            switch reason {
            case .sectionBelowBounds:
                resignFirstResponder() //selectRow(at: indexPathForLastRowInLastSection)
                
            case .sectionAboveBounds:
                resignFirstResponder() //selectRow(at: .first)
                
            case .rowAboveBounds:
                selectRow(at: indexPath.nextSection())
                
            case .rowBelowBounds:
                let section = indexPath.section - 1
                
                if let row = lastRow(in: section) {
                    selectRow(at: IndexPath(row: row, section: section))
                }
                else {
                    selectRow(at: IndexPath(row: .zero, section: section))
                }
            }
            
        case .success:
            var selectedIndexPath: IndexPath? {
                guard let delegate = delegate else {
                    return indexPath
                }
                
                return delegate.tableView?(self, willSelectRowAt: indexPath)
            }
            
            guard let validIndexPath = selectedIndexPath else {
                switch indexPathForSelectedRow?.compare(indexPath) {
                case .orderedDescending:
                    selectRow(at: indexPath.previousRow())
                    
                case .none:
                    selectRow(at: indexPath.nextRow())
                    
                case .orderedSame:
                    return
                    
                case .orderedAscending:
                    selectRow(at: indexPath.nextRow())
                }
                return
            }
            
            _selectRow(at: validIndexPath)
        }
    }
    
}

// MARK: - Selection

private extension KeyboardTableView {
    
    func _selectRow(at indexPath: IndexPath) {
        switch visibilityForRow(at: indexPath) {
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
private extension KeyboardTableView {
    
    func clearSelection() {
        selectRow(at: nil, animated: false, scrollPosition: .none)
    }

    func activateSelection() {
        guard let indexPathForSelectedRow = indexPathForSelectedRow else {
            return
        }
        delegate?.tableView?(self, didSelectRowAt: indexPathForSelectedRow)
    }
    
    func selectPrevious() {
        guard let currentSelection = indexPathForSelectedRow else {
            return selectRow(at: indexPathForLastRowInLastSection)
        }
        
        selectRow(at: currentSelection.previousRow())
    }

    func selectNext() {
        guard let currentSelection = indexPathForSelectedRow else {
            return selectRow(at: .first)
        }
        
        selectRow(at: currentSelection.nextRow())
    }
}

// MARK: - Cell Visibility

private extension KeyboardTableView {
    
    /// Whether a row is fully visible, or if not if it’s above or below the viewport.
    enum RowVisibility {
        case fullyVisible
        case notFullyVisible(ScrollPosition)
    }

    /// Whether the given row is fully visible, or if not if it’s above or below the viewport.
    func visibilityForRow(at indexPath: IndexPath) -> RowVisibility {
        let rowRect = rectForRow(at: indexPath)
        
        if bounds.inset(by: adjustedContentInset).contains(rowRect) {
            return .fullyVisible
        }

        let position: ScrollPosition = rowRect.midY < bounds.midY ? .top : .bottom
        
        return .notFullyVisible(position)
    }
    
}

