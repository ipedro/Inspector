//
//  SeparatorView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class SeparatorView: BaseView {
    let thickness: CGFloat
    
    init(thickness: CGFloat = 0.5, frame: CGRect = .zero) {
        self.thickness = thickness
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var separatorView = UIView().then {
        if #available(iOS 13.0, *) {
            $0.backgroundColor = .separator
        } else {
            $0.backgroundColor = .lightGray
        }
        
        $0.heightAnchor.constraint(equalToConstant: thickness).isActive = true
    }
    
    override func setup() {
        super.setup()
        
        contentView.addArrangedSubview(separatorView)
    }
}
