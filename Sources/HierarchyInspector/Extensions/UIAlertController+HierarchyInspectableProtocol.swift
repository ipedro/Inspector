//
//  UIAlertController+HierarchyInspectableProtocol.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - HierarchyInspectorPresentable

extension UIAlertController: HierarchyInspectorPresentable {
    
    public var hierarchyInspectorSnapshot: HierarchyInspector.ViewHierarchySnapshot? {
        get {
            nil
        }
        set {
            // TODO: fix me
        }
    }
    
    static var sharedHierarchyInspectorViews: [HierarchyInspector.Layer: [HierarchyInspectorView]] = [:] {
        didSet {
            guard oldValue.isEmpty == false, sharedHierarchyInspectorViews.isEmpty else {
                return
            }
            
            for views in oldValue.values {
                views.forEach { $0.removeFromSuperview() }
            }
        }
    }
    
    public var hierarchyInspectorViews: [HierarchyInspector.Layer: [HierarchyInspectorView]] {
        get {
            Self.sharedHierarchyInspectorViews
        }
        set {
            Self.sharedHierarchyInspectorViews = newValue
        }
    }
    
    public var hierarchyInspectorLayers: [HierarchyInspector.Layer] {
        [
            HierarchyInspector.Layer(name: "Hierarchy Inspector") { element -> Bool in
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
