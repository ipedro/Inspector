//
//  HierarchyInspectorCellViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro on 12.04.21.
//

import Foundation

enum HierarchyInspectorCellViewModel {
    case layerAction(HierarchyInspectorLayerAcionCellViewModelProtocol)
    case snaphot(HierarchyInspectorSnapshotCellViewModelProtocol)
    
    var cellClassForCoder: AnyClass {
        switch self {
        case .layerAction:
            return HierarchyInspectorLayerActionCell.classForCoder()
            
        case .snaphot:
            return HierarchyInspectorSnapshotCell.classForCoder()
        }
    }
}
