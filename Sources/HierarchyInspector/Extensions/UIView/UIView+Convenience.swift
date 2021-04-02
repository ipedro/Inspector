//
//  UIKit+Convenience.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

enum ViewPosition {
    case onTop, onBottom
}

enum ViewBinding {
    
    case centerX
    
    case centerXY
    
    case centerY
    
    case margins(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat)
    
    case autoResizingMask(UIView.AutoresizingMask)
    
    static let autoResizingMask = ViewBinding.autoResizingMask([.flexibleWidth, .flexibleHeight])
    
    static func margins(_ margins: CGFloat) -> ViewBinding {
        .margins(top: margins, leading: margins, bottom: margins, trailing: margins)
    }
    
    static func margins(horizontal: CGFloat, vertical: CGFloat) -> ViewBinding {
        .margins(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
    
    static func insets(_ insets: UIEdgeInsets) -> ViewBinding {
        .margins(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
    }
    
    static func insets(_ insets: NSDirectionalEdgeInsets) -> ViewBinding {
        .margins(top: insets.top, leading: insets.leading, bottom: insets.bottom, trailing: insets.trailing)
    }
}

extension UIView {
    
    var allSubviews: [UIView] {
        subviews.flatMap { [$0] + $0.allSubviews }
    }
    
    var originalSubviews: [UIView] {
        subviews.filter { $0 is LayerViewProtocol == false }
    }
    
    func installView(_ view: UIView, _ binding: ViewBinding = .margins(.zero), _ position: ViewPosition = .onTop, priority: UILayoutPriority = .defaultHigh) {
        switch position {
        case .onTop:
            addSubview(view)
            
        case .onBottom:
            insertSubview(view, at: .zero)
        }
        
        let constraints: [NSLayoutConstraint]
        
        switch binding {
        case .centerX:
            constraints = [
                view.centerXAnchor.constraint(equalTo: centerXAnchor)
            ]
            
        case .centerY:
            constraints = [
                view.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        
        case .centerXY:
            constraints = [
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        
        case let .autoResizingMask(mask):
            view.autoresizingMask = mask
            return
            
        case let .margins(top, leading, bottom, trailing):
            constraints = [
                view.topAnchor.constraint(equalTo: topAnchor, constant: top),
                view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading),
                view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottom),
                view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -trailing)
            ]
        }
        
        constraints.forEach { $0.priority = priority }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
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
