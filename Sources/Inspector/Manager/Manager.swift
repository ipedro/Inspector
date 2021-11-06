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

@_implementationOnly import Coordinator
import UIKit

typealias Manager = Inspector.Manager

typealias Coordinator = BaseCoordinator<Void> & StartProtocol

extension Inspector {
    final class Manager: Coordinator {
        // MARK: - Properties

        weak var host: InspectorHost? {
            didSet {
                if oldValue != nil {
                    finish()
                }
                if host != nil {
                    start()
                }
            }
        }

        var swiftUIhost: InspectorSwiftUIHost? {
            didSet {
                host = swiftUIhost
            }
        }

        var interactionDelegates: [ObjectIdentifier: Bool] = [:]

        let operationQueue = OperationQueue.main

        var viewHierarchyCoordinator: ViewHierarchyCoordinator? {
            children.first(where: { $0 is ViewHierarchyCoordinator }) as? ViewHierarchyCoordinator
        }

        var viewHierarchySnaphost: ViewHierarchySnapshot? {
            viewHierarchyCoordinator?.latestSnapshot()
        }

        // MARK: - Init

        init() {
            if #available(iOS 13, *), configuration.isSwizzlingEnabled {
                UIView.startSwizzling()
            }
        }

        deinit {
            operationQueue.cancelAllOperations()
            host = nil
        }

        func reset() {
            finish()
            start()
        }

        func start() {
            if children.contains(where: { $0 is ViewHierarchyCoordinator }) {
                return
            }

            let viewHierarchyCoordinator = ViewHierarchyCoordinator(dataSource: self, delegate: self)
            viewHierarchyCoordinator.start()

            addChild(viewHierarchyCoordinator)
        }

        func finish() {
            operationQueue.cancelAllOperations()

            children.forEach { child in
                (child as? DismissablePresentationProtocol)?.dismissPresentation(animated: true)

                removeChild(child)
            }
        }
    }
}

// MARK: - Host ViewController n

extension Manager {
    var hostViewController: UIViewController? {
        host?.keyWindow?.rootViewController?.topPresentedViewController
    }
}

// MARK: - AsyncOperationProtocol

extension Manager: AsyncOperationProtocol {
    func asyncOperation(name: String = #function, execute closure: @escaping Closure) {
        let asyncOperation = MainThreadAsyncOperation(name: name, closure: closure)

        operationQueue.addOperation(asyncOperation)
    }
}
