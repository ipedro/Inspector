//
//  ElementViewHierarchyInspectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ElementViewHierarchyInspectorViewCode: BaseView {
    
    private(set) lazy var tableView = UITableView(
        .plain,
        .backgroundColor(backgroundColor),
        .viewOptions(.isOpaque(true)),
        .tableFooterView(UIView()),
        .separatorStyle(.none),
        .contentInset(bottom: ElementInspector.appearance.horizontalMargins)
    )
    
    override func setup() {
        super.setup()
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        installView(tableView)
    }
    
}
