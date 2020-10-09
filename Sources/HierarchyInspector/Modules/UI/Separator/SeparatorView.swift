//
//  SeparatorView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class SeparatorView: BaseView {
    private lazy var separatorView = UIView().then {
        if #available(iOS 13.0, *) {
            $0.backgroundColor = .separator
        } else {
            $0.backgroundColor = .lightGray
        }
        
        $0.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    override func setup() {
        super.setup()
        
        contentView.installView(separatorView)
    }
}
