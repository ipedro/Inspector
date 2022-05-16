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
        let mainTask = MainThreadOperation(name: name, closure: closure)

        guard let keyWindow = dependencies.keyWindow else {
            return operationQueue.addOperation(mainTask)
        }

        let loaderView = loaderView(title: name)

        let hideLoaderTask = hideLoaderTask(loaderView)

        let showLoaderTask = showLoaderTask(loaderView, in: keyWindow) { [weak self] _ in
            guard let self = self else { return }

            self.operationQueue.addOperation(mainTask)
            self.operationQueue.addOperation(hideLoaderTask)
        }

        operationQueue.addOperation(showLoaderTask)
    }

    private func showLoaderTask(_ loaderView: LoaderView, in window: UIWindow, completion: @escaping (Bool) -> Void) -> MainThreadOperation {
        MainThreadOperation(name: "show loader") {
            window.addSubview(loaderView)
            window.installView(loaderView, .centerXY)

            UIView.animate(
                withDuration: .short,
                animations: {
                    loaderView.transform = .identity
                },
                completion: completion
            )
        }
    }

    private func hideLoaderTask(_ loaderView: LoaderView) -> MainThreadOperation {
        MainThreadOperation(name: "hide loader") {
            loaderView.done()

            UIView.animate(
                withDuration: .average,
                delay: .veryLong,
                options: [.curveEaseInOut, .beginFromCurrentState],
                animations: {
                    loaderView.alpha = .zero
                },
                completion: { _ in
                    loaderView.removeFromSuperview()
                }
            )
        }
    }

    private func loaderView(title: String) -> LoaderView {
        LoaderView(colorScheme: dependencies.colorScheme).then {
            $0.accessibilityIdentifier = title
            $0.transform = .init(scaleX: .zero, y: .zero)
        }
    }
}
