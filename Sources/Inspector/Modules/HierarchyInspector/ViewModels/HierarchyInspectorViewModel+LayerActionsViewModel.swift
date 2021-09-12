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

extension HierarchyInspectorViewModel {
    final class CommandGroupsViewModel: HierarchyInspectorSectionViewModelProtocol {
        struct Details: InspectorActionCellViewModelProtocol {
            let title: String
            var icon: UIImage?
            var isEnabled: Bool
        }
        
        private(set) lazy var layerCommandGroups = CommandGroups()
        
        let provider: CommandGroupsProvider
        
        init(commandGroupsProvider: @escaping CommandGroupsProvider) {
            provider = commandGroupsProvider
        }
        
        var isEmpty: Bool {
            var totalActionCount = 0
            
            for group in layerCommandGroups {
                totalActionCount += group.commands.count
            }
            
            return totalActionCount == 0
        }
        
        func loadData() {
            layerCommandGroups = provider() ?? []
        }
        
        func selectRow(at indexPath: IndexPath) -> HierarchyInspectorCommand? {
            guard let closure = action(at: indexPath).closure else {
                return nil
            }
            return .execute(closure)
        }
        
        func isRowEnabled(at indexPath: IndexPath) -> Bool {
            action(at: indexPath).isEnabled
        }
        
        var numberOfSections: Int {
            layerCommandGroups.count
        }
        
        func numberOfRows(in section: Int) -> Int {
            group(in: section).commands.count
        }
        
        func titleForHeader(in section: Int) -> String? {
            group(in: section).title
        }
        
        func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel {
            let action = self.action(at: indexPath)
            
            return .action(
                Details(
                    title: action.title,
                    icon: action.icon?.resized(.actionIconSize),
                    isEnabled: action.isEnabled
                )
            )
        }
        
        private func group(in section: Int) -> CommandsGroup {
            layerCommandGroups[section]
        }
        
        private func action(at indexPath: IndexPath) -> Command {
            group(in: indexPath.section).commands[indexPath.row]
        }
    }
}
