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

import UIKit

// MARK: - UITableViewDataSource

extension ElementViewHierarchyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ElementViewHierarchyInspectorTableViewCodeCell.self, for: indexPath)
        let itemViewModel = viewModel.itemViewModel(for: indexPath)
        cell.viewModel = itemViewModel
        cell.isEvenRow = indexPath.row % 2 == 0
        cell.contentView.isUserInteractionEnabled = true

        cell.collapseButton.actionHandler = { [weak self] in
            guard let self = self else { return }

            let actions = self.viewModel.toggleContainer(at: indexPath)
            self.updateTableView(indexPath, with: actions)
        }

        cell.detailsButton.actionHandler = { [weak self] in
            guard
                let self = self,
                let itemViewModel = itemViewModel
            else { return }

            self.delegate?.viewHierarchyListViewController(
                self,
                didSelectInfo: itemViewModel.reference,
                from: self.viewModel.rootReference
            )
        }

        return cell
    }
}
