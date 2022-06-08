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

extension InspectorViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            let firstVisibleSection = viewCode.tableView.indexPathsForVisibleRows?.first?.section,
            let headerView = viewCode.tableView.headerView(forSection: firstVisibleSection)
        else {
            return
        }

        for cell in viewCode.tableView.visibleCells {
            guard let cell = cell as? HierarchyInspectorTableViewCell else { continue }

            let headerHeight: CGFloat = headerView.frame.height

            let hiddenFrameHeight = scrollView.contentOffset.y + headerHeight - cell.frame.origin.y

            if hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height {
                cell.maskFromTop(margin: max(0, hiddenFrameHeight))
            }
            else {
                break
            }
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        viewModel.isRowEnabled(at: indexPath) ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(HierarchyInspectorTableViewHeaderView.self)
        guard let title = viewModel.titleForHeader(in: section) else { return UIView() }
        header.title = title
        header.showSeparatorView = section > .zero
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewModel.titleForHeader(in: section) == nil { return .zero }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        viewCode.elementInspectorAppearance.horizontalMargins
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let command = viewModel.selectRow(at: indexPath)
        delegate?.inspectorViewController(self, didSelect: command)
    }
}
