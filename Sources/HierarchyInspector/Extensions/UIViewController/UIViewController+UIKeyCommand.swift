//
//  UIViewController+UIKeyCommand.swift
//  HierarchyInspector
//
//  Created by Pedro on 10.04.21.
//

import UIKit

extension UIViewController {
    
    static var dismissModalKeyCommand = UIKeyCommand(
        input: UIKeyCommand.inputEscape,
        action: #selector(dismissAnimated),
        title: "Close modal view"
    )
    
    @objc func dismissAnimated() {
        dismiss(animated: true)
    }
}
