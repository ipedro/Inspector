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

extension UIViewController: InspectorManageableProtocol {
    public var inspectorManager: Inspector.Manager? {
        view.window?.inspectorManager
    }
    
    // MARK: - Convenience
    
    public var inspectorBarButtonItem: UIBarButtonItem {
        UIBarButtonItem(
           title: "🧬",
           style: .plain,
           target: self,
           action: #selector(inspectorManagerPresentation)
        ).then {
            let control = UIControl()
            control.addTarget(UIViewController(), action: #selector(UIViewController.inspectorManagerPresentation), for: .touchUpInside)
            
            $0.customView = control
        }
    }
    
    @objc public func inspectorManagerPresentation() {
        inspectorManager?.present(animated: true)
    }
}
