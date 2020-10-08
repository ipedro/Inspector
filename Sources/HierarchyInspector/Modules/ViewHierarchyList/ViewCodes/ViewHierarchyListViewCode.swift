//
//  ViewHierarchyListViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListViewCode: View {
    
    private(set) lazy var inspectBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
    
    private(set) lazy var dismissBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    private(set) lazy var tableView = UITableView().then {
        $0.register(ViewHierarchyListTableViewCodeCell.self)
        
        $0.backgroundColor          = nil
        $0.directionalLayoutMargins = .margins(top: 20, bottom: 20)
        $0.rowHeight                = UITableView.automaticDimension
        $0.estimatedRowHeight       = 80
        $0.tableFooterView          = UIView()
    }
    
    override func setup() {
        super.setup()
        
        installView(tableView)
    }
    
}
