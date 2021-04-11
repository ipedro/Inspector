//
//  UIViewController+UIKeyCommand.swift
//  HierarchyInspector
//
//  Created by Pedro on 10.04.21.
//

import UIKit

extension UIViewController {
    
    static func dismissModalKeyCommand(action: Selector) -> UIKeyCommand {
        UIKeyCommand(
            .discoverabilityTitle(
                title: "Close modal view",
                key: .escape
            ),
            action: action
        )
    }
    
}
