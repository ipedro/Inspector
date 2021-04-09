//
//  HierarchyInspectableViewController.swift
//  
//
//  Created by Pedro on 08.04.21.
//

import UIKit

open class HierarchyInspectableViewController: UIViewController, HierarchyInspectorPresentable {
    
    public private(set) lazy var hierarchyInspectorManager = HierarchyInspector.Manager(host: self)
    
    open var hierarchyInspectorLayers: [ViewHierarchyLayer] { [.allViews] }
    
    open var shouldPresentHierarchyInspectorOnShake = true {
        didSet {
            switch shouldPresentHierarchyInspectorOnShake {
            case true:
                becomeFirstResponder()
                
            case false:
                resignFirstResponder()
            }
        }
    }

    override open var canBecomeFirstResponder: Bool { true }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard shouldPresentHierarchyInspectorOnShake else {
            return
        }
        
        becomeFirstResponder()
    }
    
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        switch (event?.subtype, shouldPresentHierarchyInspectorOnShake) {
        case (.motionShake, true):
            presentHierarchyInspector(animated: true)
            
        default:
            break
        }
    }

}

// MARK: - HierarchyInspectorKeyCommandPresentable

extension HierarchyInspectableViewController: HierarchyInspectorKeyCommandPresentable {
    public var hirearchyInspectorKeyCommandsSelector: Selector? {
        #selector(keyCommand(_:))
    }
    
    open override var keyCommands: [UIKeyCommand]? {
        guard let presentedViewController = presentedViewController else {
            return hierarchyInspectorKeyCommands
        }
        
        return presentedViewController.keyCommands
    }
    
    @objc
    func keyCommand(_ sender: Any) {
        hierarchyInspectorKeyCommandHandler(sender)
    }
}
