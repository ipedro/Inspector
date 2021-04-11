//
//  ElementInspectorPanelViewControllerProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 15.10.20.
//

import UIKit

typealias ElementInspectorPanelViewController = ElementInspectorBasePanelViewController & ElementInspectorPanelViewControllerProtocol

protocol ElementInspectorPanelViewControllerProtocol: UIViewController {
    func calculatePreferredContentSize() -> CGSize
}
