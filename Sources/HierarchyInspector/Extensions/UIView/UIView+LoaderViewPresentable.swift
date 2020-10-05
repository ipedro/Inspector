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
        removeActivityIndicator()
        
        let loaderView = LoaderView.dequeueLoaderView(for: self)
        loaderView.accessibilityIdentifier = operation.name
        
        addSubview(loaderView)
        
        installView(loaderView, constraints: .centerXY)
    }
    
    func removeActivityIndicator() {
        let loaderViews = subviews.filter { $0 is LoaderView }
        
        loaderViews.forEach { $0.removeFromSuperview() }
    }
    
}
