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

extension ElementChildrenPanelViewController: UITableViewDataSource {
    #if swift(>=5.0)
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let itemViewModel = viewModel.itemViewModel(at: indexPath) else { return nil }

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { [weak self] in
                guard let self = self else { return nil }
                return self.delegate?.elementChildrenPanelViewController(self, previewFor: itemViewModel.reference)
            },
            actionProvider: { [weak self] _ in
                self?.menuAction(
                    title: itemViewModel.title,
                    image: itemViewModel.thumbnailImage,
                    for: itemViewModel.reference,
                    options: .displayInline,
                    at: indexPath
                )
            }
        )
    }

    @available(iOS 13.0, *)
        private func menuAction(
            title: String,
            subtitle: String? = nil,
            image: UIImage?,
            for reference: ViewHierarchyReference,
            options: UIMenu.Options = .init(),
            includeCellActions: Bool = true,
            at indexPath: IndexPath
        ) -> UIMenu {
        let childrenActions: UIMenu? = {
            let count = reference.children.count

            guard count > .zero else { return nil }

            return UIMenu(
                title: "Children (\(count))",
                options: count < ElementInspector.configuration.childrenListMaximumInteractiveDepth ? .displayInline : .init(),
                children: menuChildReferenceActions(for: reference.children)
            )
        }()

        let elementActions = UIMenu(
            title: "Open",
            options: .displayInline,
            children: ElementInspectorPanel.cases(for: reference).map { panel in
                UIAction(
                    title: "Open \(panel.title)",
                    image: panel.image
                ) { [weak self] _ in
                    guard let self = self else { return }

                    self.delegate?.elementChildrenPanelViewController(
                        self,
                        didSelect: reference,
                        with: panel,
                        from: self.viewModel.rootReference
                    )
                }
            }
        )

        let isCollapsed = self.viewModel.itemViewModel(at: indexPath)?.isCollapsed == true

        let cellActions: UIMenu? = {
            guard includeCellActions else { return nil }

            let collapseContainer: UIAction? = {
                guard reference.isContainer else { return nil }

                return UIAction.collapseAction(isCollapsed) { [weak self] _ in
                    self?.toggleCollapse(at: indexPath)
                }
            }()

            return UIMenu(
                title: "Cell Actions",
                options: .displayInline,
                children: [
                    collapseContainer
                ].compactMap { $0 }
            )
        }()

        return UIMenu(
            title: title,
            image: image,
            options: options,
            children: [
                cellActions,
                elementActions,
                childrenActions
            ].compactMap { $0 }
        ).then {
            $0.safeSubtitle = subtitle
        }
    }

    @available(iOS 13.0, *)
    private func menuChildReferenceActions(for references: [ViewHierarchyReference]) -> [UIMenuElement] {
        references.enumerated().map { row, reference in
            menuAction(
                title: reference.elementName,
                subtitle: reference.accessibilityIdentifier == nil ? reference.superclassName : reference.classNameWithoutQualifiers,
                image: viewModel.image(for: reference),
                for: reference,
                includeCellActions: false,
                at: IndexPath(row: row, section: .zero)
            )
        }

    }
    #endif

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ElementChildrenPanelTableViewCodeCell.self, for: indexPath)
        let itemViewModel = viewModel.itemViewModel(at: indexPath)
        cell.viewModel = itemViewModel
        cell.isEvenRow = indexPath.row % 2 == 0
        cell.contentView.isUserInteractionEnabled = true
        cell.delegate = self

        return cell
    }

    func toggleCollapse(at indexPath: IndexPath) {
        let actions = self.viewModel.toggleContainer(at: indexPath)
        updateTableView(indexPath, with: actions)
    }
}

extension ElementChildrenPanelViewController: ElementChildrenPanelTableViewCodeCellDelegate {
    func elementChildrenPanelTableViewCodeCellDidToggleCollapse(_ cell: ElementChildrenPanelTableViewCodeCell) {
        guard let indexPath = viewModel.indexPath(for: cell.viewModel) else { return }

        toggleCollapse(at: indexPath)
    }
}
