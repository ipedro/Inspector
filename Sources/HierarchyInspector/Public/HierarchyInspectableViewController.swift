//
//  HierarchyInspectableViewController.swift
//  
//
//  Created by Pedro on 08.04.21.
//

import UIKit

open class HierarchyInspectableViewController: UIViewController, HierarchyInspectorPresentable {
    
    public private(set) lazy var hierarchyInspectorManager = HierarchyInspector.Manager(host: self)
    
    open var hierarchyInspectorLayers: [ViewHierarchyLayer] = [.allViews]

    override open var canBecomeFirstResponder: Bool { true }

    open override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
    }
    
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard case .motionShake = event?.subtype else {
            return
        }

        presentHierarchyInspector(animated: true)
    }

}
