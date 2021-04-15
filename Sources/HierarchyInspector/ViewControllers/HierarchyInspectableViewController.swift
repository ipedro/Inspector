//
//  HierarchyInspectableViewController.swift
//  HierarhcyInspector
//
//  Created by Pedro on 08.04.21.
//

import UIKit

open class HierarchyInspectableViewController: UIViewController, HierarchyInspectorPresentableViewControllerProtocol, AccessibilityIdentifiersProtocol {
    
    public private(set) lazy var hierarchyInspectorManager = HierarchyInspector.Manager(
        host: self
    )
    
    public private(set) lazy var inspectBarButtonItem = UIBarButtonItem(
        title: "🧬",
        style: .plain,
        target: self,
        action: #selector(inspectBarButtonHander(_:))
    )
    
    open var hierarchyInspectorColorScheme: ViewHierarchyColorScheme { .default }
    
    open var hierarchyInspectorLayers: [ViewHierarchyLayer] { [] }
    
    open var hierarchyInspectorElements: [HierarchyInspectorElementLibraryProtocol] { [] }
    
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
        
        accessibilityIdentifiersConfiguration()
        
        guard shouldPresentHierarchyInspectorOnShake else {
            return
        }
        
        becomeFirstResponder()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        hierarchyInspectorManager.removeAllLayers()
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
    public var hirearchyInspectorKeyCommandsSelector: Selector {
        #selector(keyCommandHandler(_:))
    }
    
    open override var keyCommands: [UIKeyCommand]? {
        guard let presentedViewController = presentedViewController else {
            return hierarchyInspectorKeyCommands
        }
        
        return presentedViewController.keyCommands
    }
    
}

@objc private extension HierarchyInspectableViewController {
    func keyCommandHandler(_ sender: Any) {
        hierarchyInspectorKeyCommandHandler(sender)
    }
    
    func inspectBarButtonHander(_ sender: Any) {
        presentHierarchyInspector(animated: true)
    }
}
