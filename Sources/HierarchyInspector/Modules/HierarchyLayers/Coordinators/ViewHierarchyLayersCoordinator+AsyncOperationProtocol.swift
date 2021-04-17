//
//  ViewHierarchyLayersCoordinator+AsyncOperationProtocol.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.10.20.
//

import UIKit

extension ViewHierarchyLayersCoordinator: AsyncOperationProtocol {
    
    func asyncOperation(name: String, execute closure: @escaping Closure) {
        let layerTask = MainThreadOperation(name: name, closure: closure)
        
        guard let window = dataSource?.viewHierarchyWindow else {
            return operationQueue.addOperation(layerTask)
        }
        
        let loaderView = LoaderView(
            .accessibilityIdentifier(name),
            .transform(CGAffineTransform(scaleX: 0.1, y: 0.1))
        )
        
        let showLoader = MainThreadOperation(name: "\(name): show loader") {
            window.addSubview(loaderView)
            
            window.installView(loaderView, .centerXY)
            
            UIView.animate(
                withDuration: ElementInspector.configuration.animationDuration,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 30,
                options: .curveEaseInOut,
                animations: {
                    loaderView.transform = .identity
                }
            )
        }
        
        layerTask.addDependency(showLoader)
        
        let hideLoader = MainThreadOperation(name: "\(name): hide loader") {
            loaderView.done()
            
            UIView.animate(
                withDuration: ElementInspector.configuration.animationDuration,
                delay: 1,
                options: [.curveEaseInOut, .beginFromCurrentState],
                animations: {
                    loaderView.alpha = 0
                },
                completion: { _ in
                    loaderView.removeFromSuperview()
                }
            )
            
        }
        
        hideLoader.addDependency(layerTask)
        
        operationQueue.addOperations([showLoader, layerTask, hideLoader], waitUntilFinished: false)
    }
    
}
