//
//  UIView+LoaderViewPresentable.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

// MARK: - LoaderViewPresentable

extension UIView: LoaderViewPresentable {
    
    func showActivityIndicator(for operation: HierarchyInspector.Manager.Operation) {
        let loaderView = LoaderView.dequeueLoaderView(for: operation, in: self)
        
        addSubview(loaderView)
        
        installView(loaderView, constraints: .centerXY)
    }
    
    func removeActivityIndicator(for operation: HierarchyInspector.Manager.Operation) {
        let loaderViews = subviews.compactMap { $0 as? LoaderView }
        
        loaderViews.forEach { $0.done() }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 1,
            options: [.curveEaseInOut, .beginFromCurrentState],
            animations: {
                loaderViews.forEach { loaderView in
                    guard loaderView.currentOperation == operation else {
                        return
                    }
                    
                    loaderView.alpha = 0
                }
            },
            completion: { finished in
                guard finished else {
                    return
                }
                
                loaderViews.forEach { loaderView in
                    guard loaderView.currentOperation == operation else {
                        return
                    }
                    
                    loaderView.removeFromSuperview()
                }
            }
        )
        
    }
    
}
