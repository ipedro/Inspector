//
//  SeparatorView.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 08.10.20.
//

import UIKit

final class SeparatorView: BaseView {
    let thickness: CGFloat
    
    init(thickness: CGFloat = 0.5, color: UIColor? = nil, frame: CGRect = .zero) {
        self.thickness = thickness
        
        super.init(frame: frame)
        
        if let color = color {
            backgroundColor = color
            return
        }
        
        #if swift(>=5.0)
        if #available(iOS 13.0, *) {
            backgroundColor = .separator
        }
        else {
            backgroundColor = .lightGray
        }
        #else
        backgroundColor = .lightGray
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        heightAnchor.constraint(equalToConstant: thickness).isActive = true
    }
}
