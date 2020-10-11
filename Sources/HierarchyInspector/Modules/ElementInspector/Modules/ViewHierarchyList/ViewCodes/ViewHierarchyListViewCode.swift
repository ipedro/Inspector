//
//  ViewHierarchyListViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListViewCode: BaseView {
    
    private(set) lazy var tableView = UITableView().then {
        $0.register(ViewHierarchyListTableViewCodeCell.self)
        
        $0.backgroundColor = nil
        $0.rowHeight       = UITableView.automaticDimension
        $0.tableFooterView = UIView()
        $0.separatorStyle  = .none
        $0.estimatedRowHeight = 137
//        $0.contentInset = UIEdgeInsets(
//            top: 11,
//            left: 0,
//            bottom: 0,
//            right: 0
//        )
    }
    
    override func setup() {
        super.setup()
        
        installView(tableView)
    }
    
}
