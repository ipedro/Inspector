//
//  ViewHierarchyListViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListViewCode: BaseView {
    
    private(set) lazy var inspectBarButtonItem = UIBarButtonItem(title: "🧬", style: .plain, target: nil, action: nil)
    
    private(set) lazy var dismissBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    private(set) lazy var elementInspectorInputList = ElementInspector.InputListViewCode(frame: CGRect(x: 0, y: 0, width: 0, height: 570))
    
    private(set) lazy var tableView = UITableView().then {
        $0.register(ViewHierarchyListTableViewCodeCell.self)
        $0.tableHeaderView = elementInspectorInputList
        $0.backgroundColor = nil
        $0.rowHeight       = UITableView.automaticDimension
        $0.tableFooterView = UIView()
        $0.separatorStyle  = .none
    }
    
    override func setup() {
        super.setup()
        
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        }
        
        installView(tableView)
    }
    
}
