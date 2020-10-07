//
//  ViewHierarchyListViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListViewCode: InternalView {
    
    private(set) lazy var tableView = UITableView(frame: frame, style: .plain).then {
        $0.register(ViewHierarchyListTableViewCodeCell.self)
        
        $0.backgroundColor    = nil
        $0.directionalLayoutMargins = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        $0.rowHeight          = UITableView.automaticDimension
        $0.estimatedRowHeight = 70
        $0.tableFooterView    = UIView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        installView(tableView, constraints: .allMargins(.zero))
    }
    
}
