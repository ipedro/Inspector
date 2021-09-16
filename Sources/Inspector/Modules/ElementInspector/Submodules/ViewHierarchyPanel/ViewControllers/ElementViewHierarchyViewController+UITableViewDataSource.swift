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
    #if swift(>=5.0)
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard
            let itemViewModel = viewModel.itemViewModel(at: indexPath),
            itemViewModel.availablePanels.isEmpty == false
        else {
            return nil
        }

        return UIContextMenuConfiguration(
            identifier: indexPath.description as NSString,
            previewProvider: nil
        ) { _ in

            let actions = self.menuAction(
                title: itemViewModel.title,
                image: itemViewModel.thumbnailImage,
                options: .displayInline,
                for: itemViewModel.reference
            )

            return UIMenu(
                title: itemViewModel.title,
                image: itemViewModel.thumbnailImage,
                children: [actions]
            )
        }
    }

    @available(iOS 13.0, *)
        private func menuAction(title: String, image: UIImage?, options: UIMenu.Options = .init(), for reference: ViewHierarchyReference) -> UIMenuElement {
        let subviewsActions: [UIMenuElement] = {
            let actions: [UIMenuElement]

            switch reference.children.count {
            case .zero:
                return []

            case 1:
                actions = menuChildReferenceActions(for: reference.children)

            default:
                actions = [
                    UIMenu(
                        title: "Children",
                        children: menuChildReferenceActions(for: reference.children)
                    )
                ]
            }

            return actions.insideDivider()
        }()

        let actions = ElementInspectorPanel.cases(for: reference).map { panel in
            UIAction(title: panel.title, image: panel.image) { [weak self] _ in
                guard let self = self else { return }

                self.delegate?.viewHierarchyListViewController(
                    self,
                    didSelect: reference,
                    with: panel,
                    from: self.viewModel.rootReference
                )
            }
        }

        return UIMenu(
            title: title,
            image: image,
            options: options,
            children: actions + subviewsActions
        )
    }

    @available(iOS 13.0, *)
    private func menuChildReferenceActions(for references: [ViewHierarchyReference]) -> [UIMenuElement] {
        references.enumerated().map { _, reference in
            menuAction(
                title: reference.accessibilityIdentifier ?? reference.className,
                image: viewModel.image(for: reference),
                for: reference
            )
        }
    }
    #endif

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ElementViewHierarchyInspectorTableViewCodeCell.self, for: indexPath)
        let itemViewModel = viewModel.itemViewModel(at: indexPath)
        cell.viewModel = itemViewModel
        cell.isEvenRow = indexPath.row % 2 == 0
        cell.contentView.isUserInteractionEnabled = true

        cell.collapseButton.actionHandler = { [weak self] in
            guard let self = self else { return }

            let actions = self.viewModel.toggleContainer(at: indexPath)
            self.updateTableView(indexPath, with: actions)
        }

        return cell
    }
}
