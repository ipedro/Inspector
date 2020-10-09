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
        loaderView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        addSubview(loaderView)
        
        installView(loaderView, .centerXY)
        
        UIView.animate(
            withDuration: 0.33,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 30,
            options: .beginFromCurrentState,
            animations: {
                loaderView.transform = .identity
            }
        )
    }
    
    func removeActivityIndicator(for operation: HierarchyInspector.Manager.Operation) {
        let loaderViews = subviews.compactMap { $0 as? LoaderView }
        
        loaderViews.forEach { $0.done() }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            loaderViews.forEach { loaderView in
                guard loaderView.currentOperation == operation else {
                    return
                }
                
                loaderView.removeFromSuperview()
            }
        }
        
//        UIView.animate(
//            withDuration: 0.5,
//            delay: 1,
//            options: [.curveEaseInOut, .beginFromCurrentState],
//            animations: {
//                loaderViews.forEach { loaderView in
//                    guard loaderView.currentOperation == operation else {
//                        return
//                    }
//
//                    loaderView.alpha = 0
//                }
//            },
//            completion: { _ in
//                loaderViews.forEach { loaderView in
//                    guard loaderView.currentOperation == operation else {
//                        return
//                    }
//
//                    loaderView.removeFromSuperview()
//                }
//            }
//        )
        
    }
    
}
