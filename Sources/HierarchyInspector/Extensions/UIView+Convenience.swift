//
//  UIKit+Convenience.swift
//  
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

enum ViewPosition {
    case top, bottom
}

enum ViewConstraints {
    case centerXY
    case margins(horizontal: CGFloat = 0, vertical: CGFloat = 0)
}

extension UIView {

    func installView(_ view: UIView, constraints: ViewConstraints = .margins(), position: ViewPosition = .top) {
        switch position {
        case .top:
            addSubview(view)
            
        case .bottom:
            insertSubview(view, at: 0)
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        switch constraints {
        case .centerXY:
            NSLayoutConstraint.activate([
                centerXAnchor.constraint(equalTo: view.centerXAnchor),
                centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
        case let .margins(horizontal, vertical):
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontal),
                trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontal),
                topAnchor.constraint(equalTo: view.topAnchor, constant: vertical),
                bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -vertical)
            ])
        }
        
    }
    
    /**
     A Boolean value that determines whether the view is hidden and works around a [UIStackView bug](http://www.openradar.me/25087688) affecting iOS 9.2+.
     */
    var isSafelyHidden: Bool {
        get {
            isHidden
        }
        set {
            isHidden = false
            isHidden = newValue
        }
    }
}
