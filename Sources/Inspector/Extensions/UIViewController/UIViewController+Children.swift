//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit

extension UIViewController {
    var allPresentedViewControllers: [UIViewController] {
        var allPresentedViewControllers = [UIViewController]()
        
        var viewController: UIViewController? = self
        
        while viewController != nil {
            guard
                let presented = viewController?.presentedViewController,
                !(presented is InspectorViewController)
            else {
                return allPresentedViewControllers
            }
            allPresentedViewControllers.append(presented)
            viewController = presented
        }
        
        return allPresentedViewControllers
    }
    
    var allChildren: [UIViewController] {
        children.flatMap { [$0] + $0.allChildren }
    }
    
    var allActiveChildren: [UIViewController] {
        activeChildren.flatMap { [$0] + $0.allActiveChildren }
    }
    
    var activeChildren: [UIViewController] {
        switch self {
        case let tabBarController as UITabBarController:
            guard let selectedViewController = tabBarController.selectedViewController else {
                return []
            }
            return [selectedViewController]
            
        case let navigationController as UINavigationController:
            guard let topViewController = navigationController.topViewController else {
                return []
            }
            return [topViewController]
            
        default:
            return children
                .filter(\.isViewLoaded)
                .filter { $0.view.window != nil }
        }
    }
}
