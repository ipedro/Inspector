//
//  HierarchyInspectorViewModel+ActionGroupsViewModel.swift
//  
//
//  Created by Pedro on 10.04.21.
//

import UIKit

extension HierarchyInspectorViewModel {
    final class ActionGroupsViewModel: HierarchyInspectorViewModelSectionProtocol {
        
        struct Details: HierarchyInspectorLayerAcionCellViewModelProtocol {
            let title: String
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
        
        func selectRow(at indexPath: IndexPath) -> ViewHierarchyReference? {
            let selectedAction = action(at: indexPath)
            
            DispatchQueue.main.async {
                selectedAction.closure?()
            }
            
            return nil
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
