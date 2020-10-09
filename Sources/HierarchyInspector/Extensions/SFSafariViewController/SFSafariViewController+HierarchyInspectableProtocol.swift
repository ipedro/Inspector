//
//  SFSafariViewController+HierarchyInspectableProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 06.10.20.
//

import SafariServices

// MARK: - HierarchyInspectorPresentable

extension SFSafariViewController: HierarchyInspectorPresentable {
    public var hierarchyInspectorManager: HierarchyInspector.Manager {
        guard
            let existingManager = Self.sharedHierarchyInspectorManager,
            existingManager.hostViewController === self
        else {
            
            let newManager = HierarchyInspector.Manager(host: self).then {
                $0.shouldCacheViewHierarchySnapshot = false
            }
            
            Self.sharedHierarchyInspectorManager = newManager
            
            return newManager
        }
        
        return existingManager
    }

    public var hierarchyInspectorLayers: [ViewHierarchyLayer] {
        [
            .staticTexts,
            .stackViews,
            .containerViews
        ]
    }
}

extension SFSafariViewController {
    static var sharedHierarchyInspectorManager: HierarchyInspector.Manager? {
        didSet {
            guard let previousManager = oldValue else {
                return
            }

            previousManager.invalidate()
        }
    }
}
