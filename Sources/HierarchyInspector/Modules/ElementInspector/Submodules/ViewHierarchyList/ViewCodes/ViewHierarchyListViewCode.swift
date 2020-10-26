//
//  ViewHierarchyListViewCode.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

final class ViewHierarchyListViewCode: BaseView {
    
    private(set) lazy var activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge).then {
        $0.color = ElementInspector.appearance.tertiaryTextColor
        $0.startAnimating()
    }
    
    private(set) lazy var tableView = UITableView().then {
        $0.register(ViewHierarchyListTableViewCodeCell.self)
        $0.backgroundView     = activityIndicatorView
        $0.backgroundColor    = backgroundColor
        $0.isOpaque           = true
        $0.rowHeight          = UITableView.automaticDimension
        $0.tableFooterView    = UIView()
        $0.separatorStyle     = .none
        $0.estimatedRowHeight = 120
        $0.contentInset       = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: ElementInspector.appearance.horizontalMargins,
            right: 0
        )
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = ElementInspector.appearance.panelBackgroundColor
        
        installView(tableView)
    }
    
}
