//
//  LoaderViewPresentable.swift
//  
//
//  Created by Pedro Almeida on 02.10.20.
//

import UIKit

protocol LoaderViewPresentable: UIView {
    
    func showActivityIndicator()
    
    func removeActivityIndicator()
    
}

extension LoaderViewPresentable {
    func showActivityIndicator() {
        removeActivityIndicator()
        
        let loaderView = LoaderView.dequeueLoaderView(for: self)
        
        addSubview(loaderView)
        
        installView(loaderView, constraints: .centerXY)
    }
    
    func removeActivityIndicator() {
        let loaderViews = subviews.filter { $0 is LoaderView }
        
        loaderViews.forEach { $0.removeFromSuperview() }
    }
}
