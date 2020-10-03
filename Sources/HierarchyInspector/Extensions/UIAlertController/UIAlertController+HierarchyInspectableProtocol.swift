//
//  UIAlertController+HierarchyInspectableProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectorPresentable

extension UIAlertController: HierarchyInspectorPresentable {
    public var hierarchyInspectorManager: HierarchyInspector.Manager {
        guard
            let existingManager = Self.currentHierarchyInspectorManager,
            existingManager.hostViewController === self
        else {
            
            let newManager = HierarchyInspector.Manager(host: self)
            Self.currentHierarchyInspectorManager = newManager
            
            return newManager
        }
        
        return existingManager
    }

    public var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        [
            .layer(name: "Alert controller") { element -> Bool in
                let denyList = [
                    Texts.closeInspector,
                    Texts.stopInspecting,
                    Texts.hierarchyInspector
                ]

                if let label = element as? UILabel, let text = label.text {
                    return denyList.contains(text) == false
                }

                let labels = element.subviews.filter {
                    guard
                        let label = $0 as? UILabel,
                        let text = label.text
                    else {
                        return false
                    }

                    return denyList.contains(text)
                }

                return labels.isEmpty
            }
        ]
    }
}

private extension UIAlertController {
    static var currentHierarchyInspectorManager: HierarchyInspector.Manager? {
        didSet {
            guard let previousManager = oldValue else {
                return
            }

            previousManager.removeAllLayers()
        }
    }
}
