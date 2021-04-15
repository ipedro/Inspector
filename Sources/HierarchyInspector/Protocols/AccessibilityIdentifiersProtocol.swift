//
//  AccessibilityIdentifiersProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro on 15.04.21.
//

import UIKit

public protocol AccessibilityIdentifiersProtocol {
    func accessibilityIdentifiersConfiguration(for view: UIView)
}

public extension AccessibilityIdentifiersProtocol {
    func accessibilityIdentifiersConfiguration(for view: UIView) {
        #if DEBUG
        let mirror = Mirror(reflecting: view)
        mirror.subviewsAccessibilityIdentifiers()

        if let self = self as? UIViewController {
            self.navigationController?.navigationBar.accessibilityIdentifier = "\(type(of: self)).navigationBar"
        }

        if let self = self as? UITabBarController {
            self.tabBar.accessibilityIdentifier = "\(type(of: self)).tabBar"
        }
        #endif
    }
}
