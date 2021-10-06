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

extension ViewHierarchyCoordinator: AsyncOperationProtocol {
    func asyncOperation(name: String, execute closure: @escaping Closure) {
        let layerTask = MainThreadOperation(name: name, closure: closure)

        guard let rootView = dataSource?.rootView else {
            return operationQueue.addOperation(layerTask)
        }

        let loaderView = LoaderView(colorScheme: dataSource?.colorScheme ?? .default).then {
            $0.accessibilityIdentifier = name
            $0.transform = .init(scaleX: 0.1, y: 0.1)
        }

        let showLoader = MainThreadOperation(name: "\(name): show loader") {
            rootView.addSubview(loaderView)

            rootView.installView(loaderView, .centerXY)

            UIView.animate(
                withDuration: .average,
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
                withDuration: .average,
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
