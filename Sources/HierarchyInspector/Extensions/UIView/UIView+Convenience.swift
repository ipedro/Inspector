//
//  UIKit+Convenience.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

enum ViewPosition {
    case top, bottom
}

enum ViewConstraints {
    case centerX
    case centerXY
    case margins(horizontal: CGFloat, vertical: CGFloat)
    case autoResizingMask(UIView.AutoresizingMask = [.flexibleWidth, .flexibleHeight])
    
    static func allMargins(_ margins: CGFloat) -> ViewConstraints {
        .margins(horizontal: margins, vertical: margins)
    }
}

extension UIView {
    
    var allSubviews: [UIView] {
        subviews.flatMap { [$0] + $0.allSubviews }
    }
    
    var originalSubviews: [UIView] {
        subviews.filter { $0 is InternalViewProtocol == false }
    }
    
    func installView(_ view: UIView, constraints constraintOptions: ViewConstraints = .autoResizingMask(), position: ViewPosition = .top) {
        switch position {
        case .top:
            addSubview(view)
            
        case .bottom:
            insertSubview(view, at: .zero)
        }
        
        let constraints: [NSLayoutConstraint]
        
        switch constraintOptions {
        case .centerX:
            constraints = [
                view.centerXAnchor.constraint(equalTo: centerXAnchor)
            ]
        
        case .centerXY:
            constraints = [
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        
        case let .autoResizingMask(mask):
            view.autoresizingMask = mask
            return
            
        case let .margins(horizontal, vertical):
            constraints = [
                view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontal),
                view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontal),
                view.topAnchor.constraint(equalTo: topAnchor, constant: vertical),
                view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -vertical)
            ]
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.forEach { $0.priority = .defaultLow }
        
        NSLayoutConstraint.activate(constraints)
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
