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
    final class ActionGroupsViewModel: HierarchyInspectorSectionViewModelProtocol {
        
        struct Details: HierarchyInspectorLayerAcionCellViewModelProtocol {
            let title: String
            var icon: UIImage?
            var isEnabled: Bool
        }
        
        private(set) lazy var layerActionGroups = ActionGroups()
        
        let provider: ActionGroupsProvider
        
        init(actionGroupsProvider: @escaping ActionGroupsProvider) {
            provider = actionGroupsProvider
        }
        
        var isEmpty: Bool {
            var totalActionCount = 0
            
            for group in layerActionGroups {
                totalActionCount += group.actions.count
            }
            
            return totalActionCount == 0
        }
        
        func loadData() {
            layerActionGroups = provider() ?? []
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
            layerActionGroups.count
        }
        
        func numberOfRows(in section: Int) -> Int {
            actionGroup(in: section).actions.count
        }
        
        func titleForHeader(in section: Int) -> String? {
            actionGroup(in: section).title
        }
        
        func cellViewModelForRow(at indexPath: IndexPath) -> HierarchyInspectorCellViewModel {
            let action = self.action(at: indexPath)
            
            return .layerAction(
                Details(
                    title: action.title,
                    icon: action.icon,
                    isEnabled: action.isEnabled
                )
            )
        }
        
        private func actionGroup(in section: Int) -> ActionGroup {
            layerActionGroups[section]
        }
        
        private func action(at indexPath: IndexPath) -> Action {
            actionGroup(in: indexPath.section).actions[indexPath.row]
        }
    }
}
