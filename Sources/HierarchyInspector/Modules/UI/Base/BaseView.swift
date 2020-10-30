//
//  BaseView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 07.10.20.
//

import UIKit

class BaseView: UIView {
    
    private(set) lazy var contentView = UIStackView(axis: .vertical).then {
        installView($0)
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    func setup() {
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        #endif
    }
    
}
