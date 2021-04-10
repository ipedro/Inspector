//
//  ElementViewHierarchyInspectorViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ElementViewHierarchyInspectorViewCode: BaseView {
    
    private(set) lazy var tableView = UITableView().then {
        $0.register(ElementViewHierarchyInspectorTableViewCodeCell.self)
        $0.backgroundColor = backgroundColor
        $0.isOpaque        = true
        $0.tableFooterView = UIView()
        $0.separatorStyle  = .none
        $0.contentInset    = .insets(bottom: ElementInspector.appearance.horizontalMargins)
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        installView(tableView)
    }
    
}
